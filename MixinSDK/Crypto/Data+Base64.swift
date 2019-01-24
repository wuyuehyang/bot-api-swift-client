//
//  Data+Base64.swift
//  MixinSDK
//
//  Created by wuyuehyang on 2019/1/23.
//  Copyright © 2019 wuyuehyang. All rights reserved.
//

import Foundation

extension Data {
    
    func base64URLEncodedString() -> String {
        var str = base64EncodedString()
        str = str.replacingOccurrences(of: "+", with: "-")
        str = str.replacingOccurrences(of: "/", with: "_")
        str = str.replacingOccurrences(of: "=", with: "")
        return str
    }
    
}
