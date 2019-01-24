//
//  Network.swift
//  MixinSDK
//
//  Created by wuyuehyang on 2019/1/22.
//  Copyright © 2019 wuyuehyang. All rights reserved.
//

import Foundation

private struct Response<DataType: Decodable>: Decodable {
    let data: DataType?
    let error: MixinError?
}

private let session: URLSession = {
    let config = URLSessionConfiguration.default
    config.timeoutIntervalForRequest = 10
    return URLSession(configuration: config)
}()

private let jsonEncoder: JSONEncoder = {
    let encoder = JSONEncoder()
    encoder.keyEncodingStrategy = .convertToSnakeCase
    return encoder
}()

private let jsonDecoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
}()

func request<DataType: Decodable>(_ req: Request, completion: @escaping (Result<DataType, Error>) -> Void) {
    do {
        let request = try req.urlRequest()
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let response = response as? HTTPURLResponse, (response.statusCode >= 200 && response.statusCode <= 299) else {
                let raw: String?
                if let data = data {
                    raw = String(data: data, encoding: .utf8)
                } else {
                    raw = nil
                }
                completion(.failure(MixinError.badResponse(raw: raw)))
                return
            }
            if let data = data {
                do {
                    let resp = try jsonDecoder.decode(Response<DataType>.self, from: data)
                    if let data = resp.data {
                        completion(.success(data))
                    } else if let error = resp.error {
                        completion(.failure(error))
                    } else {
                        let raw = String(data: data, encoding: .utf8)
                        completion(.failure(MixinError.badResponse(raw: raw)))
                    }
                } catch {
                    completion(.failure(error))
                }
            } else if let error = error {
                completion(.failure(error))
            } else {
                completion(.failure(MixinError.badResponse(raw: nil)))
            }
        }
        task.resume()
    } catch {
        completion(.failure(error))
    }
}
