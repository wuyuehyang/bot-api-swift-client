//
//  Result.swift
//  MixinSDK
//
//  Created by wuyuehyang on 2019/1/23.
//  Copyright © 2019 wuyuehyang. All rights reserved.
//

import Foundation

public enum Result<Success, Failure> {
    case success(Success)
    case failure(Failure)
}
