//
//  DateFormatter+ISO8601.swift
//  MixinSDK
//
//  Created by wuyuehyang on 2019/2/12.
//  Copyright © 2019 wuyuehyang. All rights reserved.
//

import Foundation

extension DateFormatter {
    
    static let iso8601DateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter
    }()
    
}
