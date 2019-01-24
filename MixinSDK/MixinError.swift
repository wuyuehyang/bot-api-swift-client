//
//  MixinError.swift
//  MixinSDK
//
//  Created by wuyuehyang on 2019/1/23.
//  Copyright © 2019 wuyuehyang. All rights reserved.
//

import Foundation

public enum MixinError: Error {
    
    // Server error
    case badRequest
    case forbidden
    case endPointNotFound
    case tooManyRequests
    case invalidField
    case deliverSMSFailed
    case invalidReCaptcha
    case requiredReCaptcha
    case invalidPhoneNumber
    case insufficientIdentityNumber
    case invalidInvitationCode
    case invalidPhoneVerificationCode
    case phoneVerificationCodeExpired
    case invalidQRCode
    case groupAlreadyFull
    case insufficientBalance
    case invalidPinFormat
    case incorrectPin
    case transferAmountTooSmall
    case authorizationCodeExpired
    case phoneNumberAlreadyExist
    case tooManyAppsCreated
    case insufficientFee
    case alreadyPaid
    case tooManyStickers
    case withdrawAmountTooSmall
    case outOfSync
    case missingPrivateKey
    case invalidAddressFormat
    case insufficientAssetPool
    case internalServer
    case blazeServer
    case blazeOperationTimeout
    
    case badResponse(raw: String?)
    
    case unknownServer(status: Int, code: Int, description: String)
    
    // Client error
    case keyPairGeneration(underlying: Error?)
    case parsePEMFile
    case createPrivateKeyWithPEM(underlying: Error)
    case jwtBuilding
    case jwtSign(underlying: Error)
    case invalidPinToken
    case invalidPin
}

extension MixinError: Decodable {
    
    enum CodingKeys: CodingKey {
        case status
        case code
        case description
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let status = try container.decode(Int.self, forKey: .status)
        let code = try container.decode(Int.self, forKey: .code)
        switch status {
        case 202:
            switch code {
            case 400:
                self = .badRequest
            case 403:
                self = .forbidden
            case 404:
                self = .endPointNotFound
            case 429:
                self = .tooManyRequests
            case 10002:
                self = .invalidField
            case 10003:
                self = .deliverSMSFailed
            case 10004:
                self = .invalidReCaptcha
            case 10005:
                self = .requiredReCaptcha
            case 20110:
                self = .invalidPhoneNumber
            case 20111:
                self = .insufficientIdentityNumber
            case 20112:
                self = .invalidInvitationCode
            case 20113:
                self = .invalidPhoneVerificationCode
            case 20114:
                self = .phoneVerificationCodeExpired
            case 20115:
                self = .invalidQRCode
            case 20116:
                self = .groupAlreadyFull
            case 20117:
                self = .insufficientBalance
            case 20118:
                self = .invalidPinFormat
            case 20119:
                self = .incorrectPin
            case 20120:
                self = .transferAmountTooSmall
            case 20121:
                self = .authorizationCodeExpired
            case 20122:
                self = .phoneNumberAlreadyExist
            case 20123:
                self = .tooManyAppsCreated
            case 20124:
                self = .insufficientFee
            case 20125:
                self = .alreadyPaid
            case 20126:
                self = .tooManyStickers
            case 20127:
                self = .withdrawAmountTooSmall
            case 30100:
                self = .outOfSync
            case 30101:
                self = .missingPrivateKey
            case 30102:
                self = .invalidAddressFormat
            case 30103:
                self = .insufficientAssetPool
            default:
                let description = try container.decode(String.self, forKey: .description)
                self = .unknownServer(status: status, code: code, description: description)
            }
        case 500:
            switch code {
            case 500:
                self = .internalServer
            case 7000:
                self = .blazeServer
            case 7001:
                self = .blazeOperationTimeout
            default:
                let description = try container.decode(String.self, forKey: .description)
                self = .unknownServer(status: status, code: code, description: description)
            }
        default:
            let description = try container.decode(String.self, forKey: .description)
            self = .unknownServer(status: status, code: code, description: description)
        }
    }
    
}
