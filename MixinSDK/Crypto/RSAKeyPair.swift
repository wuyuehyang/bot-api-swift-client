//
//  RSAKeyPair.swift
//  MixinSDK
//
//  Created by wuyuehyang on 2019/1/23.
//  Copyright © 2019 wuyuehyang. All rights reserved.
//

import Foundation

class RSAKeyPair {
    
    let privateKey: SecKey
    let publicKey: SecKey
    
    init(size: Int = 1024) throws {
        let params = [
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecAttrKeySizeInBits: size
            ] as CFDictionary
        var error: Unmanaged<CFError>? = nil
        guard let privateKey = SecKeyCreateRandomKey(params, &error) else {
            let retained = error!.takeRetainedValue() as Error
            throw MixinError.keyPairGeneration(underlying: retained)
        }
        guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
            throw MixinError.keyPairGeneration(underlying: nil)
        }
        self.privateKey = privateKey
        self.publicKey = publicKey
    }
    
    func x509PublicKey() throws -> Data {
        var error: Unmanaged<CFError>? = nil
        guard let cfPublicKeyData = SecKeyCopyExternalRepresentation(publicKey, &error) else {
            let retained = error!.takeRetainedValue() as Error
            throw MixinError.keyPairGeneration(underlying: retained)
        }
        let publicKeyData = cfPublicKeyData as Data
        
        return publicKeyData.dataByPrependingX509Header()
    }
    
    func pemPrivateKey() throws -> String {
        var error: Unmanaged<CFError>? = nil
        guard let privateKeyData = SecKeyCopyExternalRepresentation(privateKey, &error) else {
            let retained = error!.takeRetainedValue() as Error
            throw MixinError.keyPairGeneration(underlying: retained)
        }
        return "-----BEGIN RSA PRIVATE KEY-----\n"
            + (privateKeyData as Data).base64EncodedString()
            + "\n-----END RSA PRIVATE KEY-----"
    }
    
}

private extension Data {
    
    func dataByPrependingX509Header() -> Data {
        let result = NSMutableData()
        
        let encodingLength: Int = (self.count + 1).encodedOctets().count
        let OID: [CUnsignedChar] = [0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86,
                                    0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00]
        
        var builder: [CUnsignedChar] = []
        
        // ASN.1 SEQUENCE
        builder.append(0x30)
        
        // Overall size, made of OID + bitstring encoding + actual key
        let size = OID.count + 2 + encodingLength + self.count
        let encodedSize = size.encodedOctets()
        builder.append(contentsOf: encodedSize)
        result.append(builder, length: builder.count)
        result.append(OID, length: OID.count)
        builder.removeAll(keepingCapacity: false)
        
        builder.append(0x03)
        builder.append(contentsOf: (self.count + 1).encodedOctets())
        builder.append(0x00)
        result.append(builder, length: builder.count)
        
        // Actual key bytes
        result.append(self)
        
        return result as Data
    }
    
}

private extension NSInteger {
    
    func encodedOctets() -> [CUnsignedChar] {
        // Short form
        if self < 128 {
            return [CUnsignedChar(self)]
        }
        
        // Long form
        let i = Int(log2(Double(self)) / 8 + 1)
        var len = self
        var result: [CUnsignedChar] = [CUnsignedChar(i + 0x80)]
        
        for _ in 0..<i {
            result.insert(CUnsignedChar(len & 0xFF), at: 1)
            len = len >> 8
        }
        
        return result
    }
    
}
