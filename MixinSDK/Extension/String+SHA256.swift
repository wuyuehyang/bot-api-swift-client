//
//  String+SHA256.swift
//  MixinSDK
//
//  Created by wuyuehyang on 2019/1/23.
//  Copyright © 2019 wuyuehyang. All rights reserved.
//

import Foundation
import CommonCrypto

extension String {
    
    var sha256: String {
        guard let data = data(using: .utf8) else {
            return ""
        }
        var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        _ = data.withUnsafeBytes {
            CC_SHA256($0, CC_LONG(data.count), &hash)
        }
        return hash.map({ String(format: "%02x", $0) }).joined()
    }
    
}
