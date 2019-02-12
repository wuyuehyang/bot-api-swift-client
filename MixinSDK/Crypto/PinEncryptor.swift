//
//  PinEncryptor.swift
//  MixinSDK
//
//  Created by wuyuehyang on 2019/1/24.
//  Copyright © 2019 wuyuehyang. All rights reserved.
//

import Foundation
import MXNRsaOaepDecryptor
import CommonCrypto

public typealias EncryptedPinToken = String

class PinEncryptor {
    
    private let aesBlockSize = 16 // in bytes
    private let credential: Credential
    private let pinToken: Data
    
    init(credential: Credential) throws {
        self.credential = credential
        let decryptor = MXNRsaOaepDecryptor(derFormattedPrivateKey: credential.derFormattedPrivateKey)
        guard let pinTokenData = Data(base64Encoded: credential.pinToken) else {
            throw MixinError.invalidPinToken
        }
        guard let sessionIdData = credential.sessionId.data(using: .utf8) else {
            throw MixinError.invalidSessionId
        }
        pinToken = try decryptor.decrypted(fromCipher: pinTokenData, label: sessionIdData)
    }
    
    func encrypt(pin: String, iterator: UInt64) throws -> String {
        guard let pinData = pin.data(using: .utf8) else {
            throw MixinError.invalidPin
        }
        guard let iv = Data(withSecuredRandomBytesOfCount: aesBlockSize) else {
            throw MixinError.generateSecuredRandom
        }
        var time = UInt64(Date().timeIntervalSince1970).littleEndian
        let timeData = Data(bytes: &time, count: MemoryLayout<UInt64>.size)
        var iterator = iterator.littleEndian
        let iteratorData = Data(bytes: &iterator, count: MemoryLayout<UInt64>.size)
        let raw = pinData + timeData + iteratorData
        let paddingLength = aesBlockSize - raw.count % aesBlockSize
        let padded = raw + Data(repeating: UInt8(paddingLength), count: paddingLength)
        let encrypted = try aesEncrypted(plain: padded, key: pinToken, iv: iv)
        return (iv + encrypted).base64EncodedString()
    }
    
    private func aesEncrypted(plain: Data, key: Data, iv: Data) throws -> Data {
        var maybeCryptor: CCCryptorRef?
        var status = pinToken.withUnsafeBytes { (pinTokenBytes) -> CCCryptorStatus in
            iv.withUnsafeBytes({ (ivBytes) -> CCCryptorStatus in
                CCCryptorCreate(CCOperation(kCCEncrypt), CCAlgorithm(kCCAlgorithmAES), 0, pinTokenBytes, pinToken.count, ivBytes, &maybeCryptor)
            })
        }
        guard status == kCCSuccess, let cryptor = maybeCryptor else {
            throw MixinError.aesCryptorInit(code: status)
        }
        
        defer {
            CCCryptorRelease(cryptor)
        }
        
        let outputSize = CCCryptorGetOutputLength(cryptor, plain.count, true)
        guard let outputBuffer = malloc(outputSize) else {
            throw MixinError.aesOutputBufferAllocation
        }
        
        var dataOutMoved = 0
        status = plain.withUnsafeBytes { (plainBytes) -> CCCryptorStatus in
            CCCryptorUpdate(cryptor, plainBytes, plain.count, outputBuffer, outputSize, &dataOutMoved)
        }
        guard status == kCCSuccess else {
            free(outputBuffer)
            throw MixinError.aesCryptorUpdate(code: status)
        }
        
        status = CCCryptorFinal(cryptor, outputBuffer, outputSize - dataOutMoved, &dataOutMoved)
        guard status == kCCSuccess else {
            free(outputBuffer)
            throw MixinError.aesCryptorFinal(code: status)
        }
        
        return Data(bytesNoCopy: outputBuffer, count: outputSize, deallocator: .free)
    }
    
}
