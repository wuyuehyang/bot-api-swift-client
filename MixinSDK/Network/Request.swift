//
//  Request.swift
//  MixinSDK
//
//  Created by wuyuehyang on 2019/1/23.
//  Copyright © 2019 wuyuehyang. All rights reserved.
//

import Foundation

class Request {
    
    typealias Parameters = [String: String]?
    
    let method: HTTPMethod
    let url: URL
    let parameters: Data?
    let credential: Credential
    
    init(method: HTTPMethod, url: MixinURL, parameters: Parameters = nil, credential: Credential) {
        self.method = method
        self.url = url.urlValue
        if let params = parameters {
            self.parameters = try! JSONSerialization.data(withJSONObject: params, options: [])
        } else {
            self.parameters = nil
        }
        self.credential = credential
    }
    
    func urlRequest() throws -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        if let parameters = parameters {
            switch method {
            case .get:
                break // FIXME
            case .post:
                request.httpBody = parameters
            }
        }
        let token = try signedAuthenticationToken()
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "Authorization": "Bearer " + token
        ]
        return request
    }
    
    private func signedAuthenticationToken() throws -> String {
        var sig = method.rawValue + "/" + url.relativeString
        if method == .post, let parameters = parameters, let body = String(data: parameters, encoding: .utf8) {
            sig += body
        }
        let issuedAt = Date()
        let claims = JWTClaims(uid: credential.userId,
                               sid: credential.sessionId,
                               iat: issuedAt,
                               exp: issuedAt.addingTimeInterval(30 * 60),
                               jti: UUID().uuidString.lowercased(),
                               sig: sig.sha256,
                               scp: "FULL")
        return try JWT.signedToken(claims: claims, privateKey: credential.privateKey)
    }
    
}

extension Request {
    
    enum HTTPMethod: String {
        case post = "POST"
        case get = "GET"
    }
    
    enum MixinURL {
        
        private static let base = URL(string: "https://api.mixin.one")!
        
        case users
        case assets(id: String)
        
        var urlValue: URL {
            let path: String
            switch self {
            case .users:
                path = "users"
            case .assets(let id):
                path = "assets/" + id
            }
            return URL(string: path, relativeTo: MixinURL.base)!
        }
    }
    
}
