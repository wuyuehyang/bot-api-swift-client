//
//  Credential.swift
//  MixinSDK
//
//  Created by wuyuehyang on 2019/1/23.
//  Copyright © 2019 wuyuehyang. All rights reserved.
//

import Foundation

public class Credential {
    
    let userId: String
    let sessionId: String
    let privateKey: SecKey
    
    public init(userId: String, sessionId: String, pemPrivateKey: String) throws {
        self.userId = userId
        self.sessionId = sessionId
        
        let lines = pemPrivateKey.components(separatedBy: "\n").filter { line in
            !line.hasPrefix("-----BEGIN") && !line.hasPrefix("-----END")
        }
        guard let data = Data(base64Encoded: lines.joined()) else {
            throw MixinError.parsePEMFile
        }
        let param = [
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass: kSecAttrKeyClassPrivate
        ]
        var error: Unmanaged<CFError>? = nil
        guard let key = SecKeyCreateWithData(data as CFData, param as CFDictionary, &error) else {
            let retained = error!.takeRetainedValue() as Error
            throw MixinError.createPrivateKeyWithPEM(underlying: retained)
        }
        self.privateKey = key
    }
    
}
