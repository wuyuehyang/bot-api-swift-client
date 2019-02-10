//
//  MXNRsaOaepDecryptor.h
//  MixinSDK
//
//  Created by wuyuehyang on 2019/2/10.
//  Copyright © 2019 wuyuehyang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN const NSErrorDomain MXNRsaOaepDecryptorErrorDomain;
FOUNDATION_EXTERN const NSErrorUserInfoKey MXNRsaOaepDecryptorUnderlyingErrorCode;

typedef NS_ENUM(NSUInteger, MXNRsaOaepDecryptorErrorCode) {
    MXNRsaOaepDecryptorErrorCodeImportPrivateKey,
    MXNRsaOaepDecryptorErrorCodeDecryptionFailed,
    MXNRsaOaepDecryptorErrorCodeInvalidResult
};

@interface MXNRsaOaepDecryptor : NSObject

+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithDerFormattedPrivateKey:(NSData *)der;

- (NSData * _Nullable)decryptedFromCipher:(NSData *)cipher
                                    label:(NSData *)label
                                 outError:(NSError * _Nullable *)error;

@end

NS_ASSUME_NONNULL_END
