//
//  JWTBuilder.swift
//  MixinSDK
//
//  Created by wuyuehyang on 2019/1/23.
//  Copyright © 2019 wuyuehyang. All rights reserved.
//

import Foundation

struct JWTClaims: Encodable {
    let uid: String
    let sid: String
    let iat: Date
    let exp: Date
    let jti: String
    let sig: String
    let scp: String
}

struct JWT {
    
    private static let jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .custom({ (date, encoder) in
            let timeInterval = UInt64(date.timeIntervalSince1970)
            var container = encoder.singleValueContainer()
            try container.encode(timeInterval)
        })
        return encoder
    }()
    
    private static let header = "{\"alg\":\"RS512\",\"typ\":\"JWT\"}"
    private static let base64EncodedHeader = header.data(using: .utf8)!.base64URLEncodedString()
    
    static func signedToken(claims: JWTClaims, privateKey: SecKey) throws -> String {
        let base64EncodedcClaims = try jsonEncoder.encode(claims).base64URLEncodedString()
        let headerAndPayload = base64EncodedHeader + "." + base64EncodedcClaims
        guard let dataToSign = headerAndPayload.data(using: .utf8) else {
            throw MixinError.jwtBuilding
        }
        var error: Unmanaged<CFError>? = nil
        guard let signature = SecKeyCreateSignature(privateKey, .rsaSignatureMessagePKCS1v15SHA512, dataToSign as CFData, &error) else {
            let retained = error!.takeRetainedValue() as Error
            throw MixinError.jwtSign(underlying: retained)
        }
        let base64EncodedSignature = (signature as Data).base64URLEncodedString()
        return headerAndPayload + "." + base64EncodedSignature
    }
    
}
