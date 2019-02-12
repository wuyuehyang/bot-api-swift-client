//
//  Credential.swift
//  MixinSDK
//
//  Created by wuyuehyang on 2019/1/23.
//  Copyright © 2019 wuyuehyang. All rights reserved.
//

import Foundation
import CommonCrypto

public typealias PemEncodedKey = String

public class Credential {
    
    let userId: String
    let sessionId: String
    let privateKey: SecKey
    let pinToken: EncryptedPinToken
    
    let derFormattedPrivateKey: Data
    
    private static func derFormattedPrivateKey(fromPemEncodedKey key: PemEncodedKey) throws -> Data {
        let lines = key.components(separatedBy: "\n").filter { line in
            !line.hasPrefix("-----BEGIN") && !line.hasPrefix("-----END")
        }
        guard let data = Data(base64Encoded: lines.joined()) else {
            throw MixinError.parsePEMFile
        }
        return data
    }
    
    private static func privateKey(fromDerFormattedPrivateKey key: Data) throws -> SecKey {
        let param = [
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass: kSecAttrKeyClassPrivate
        ]
        var error: Unmanaged<CFError>? = nil
        guard let key = SecKeyCreateWithData(key as CFData, param as CFDictionary, &error) else {
            let retained = error!.takeRetainedValue() as Error
            throw MixinError.createPrivateKeyWithPEM(underlying: retained)
        }
        return key
    }
    
    public init(userId: String, sessionId: String, privateKey: PemEncodedKey, pinToken: EncryptedPinToken) throws {
        self.userId = userId
        self.sessionId = sessionId
        self.derFormattedPrivateKey = try Credential.derFormattedPrivateKey(fromPemEncodedKey: privateKey)
        self.privateKey = try Credential.privateKey(fromDerFormattedPrivateKey: derFormattedPrivateKey)
        self.pinToken = pinToken
    }
    
}
