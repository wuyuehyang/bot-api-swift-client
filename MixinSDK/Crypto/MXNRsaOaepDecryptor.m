//
//  MXNRsaOaepDecryptor.m
//  MixinSDK
//
//  Created by wuyuehyang on 2019/2/10.
//  Copyright © 2019 wuyuehyang. All rights reserved.
//

#import "MXNRsaOaepDecryptor.h"
#import "tomcrypt.h"

static int sha256HashIndex;

const NSErrorDomain MXNRsaOaepDecryptorErrorDomain = @"MXNRsaOaepDecryptorErrorDomain";
const NSErrorUserInfoKey MXNRsaOaepDecryptorUnderlyingErrorCode = @"MXNRsaOaepDecryptorUnderlyingErrorCode";

@interface MXNRsaOaepDecryptor ()

@property (nonatomic, copy, readwrite) NSData *der;
@property (nonatomic, assign, readwrite) size_t blockSize;
@property (nonatomic, assign, readwrite) rsa_key *key;

@end

@implementation MXNRsaOaepDecryptor

- (instancetype)initWithDerFormattedPrivateKey:(NSData *)der {
    self = [super init];
    if (self) {
        self.der = der;
    }
    return self;
}

- (void)dealloc {
    if (_key) {
        rsa_free(_key);
    }
}

- (NSData * _Nullable)decryptedFromCipher:(NSData *)cipher
                                    label:(NSData *)label
                                 outError:(NSError * _Nullable *)error {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sha256HashIndex = register_hash(&sha256_desc);
    });
    if (!_key) {
        rsa_key key;
        int result = rsa_import(_der.bytes, _der.length, &key);
        if (result != CRYPT_OK) {
            if (error) {
                NSNumber *code = [NSNumber numberWithInt:result];
                *error = [NSError errorWithDomain:MXNRsaOaepDecryptorErrorDomain
                                             code:MXNRsaOaepDecryptorErrorCodeImportPrivateKey
                                         userInfo:@{MXNRsaOaepDecryptorUnderlyingErrorCode : code}];
            }
            return nil;
        }
        _key = &key;
        _blockSize = rsa_get_size(_key);
    }
    
    NSMutableData *plain = [NSMutableData new];
    unsigned long plainSize = _blockSize;
    int validation = CRYPT_OK;
    int result = rsa_decrypt_key_ex(cipher.bytes, cipher.length, plain.mutableBytes, &plainSize, label.bytes, label.length, sha256HashIndex, LTC_PKCS_1_OAEP, &validation, _key);
    
    if (result != CRYPT_OK) {
        if (error) {
            NSNumber *code = [NSNumber numberWithInt:result];
            *error = [NSError errorWithDomain:MXNRsaOaepDecryptorErrorDomain
                                         code:MXNRsaOaepDecryptorErrorCodeDecryptionFailed
                                     userInfo:@{MXNRsaOaepDecryptorUnderlyingErrorCode : code}];
        }
        return nil;
    }
    if (!validation) {
        if (error) {
            *error = [NSError errorWithDomain:MXNRsaOaepDecryptorErrorDomain
                                         code:MXNRsaOaepDecryptorErrorCodeInvalidResult
                                     userInfo:nil];
        }
        return nil;
    }
    
    plain.length = plainSize;
    return [plain copy];
}

@end
