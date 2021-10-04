//
//  Decoder.swift
//  AlarmCall
//
//  Created by Damor on 2021/10/04.
//

import Foundation

struct Coder {
    static func model<T: Decodable>(encodedData: Data) throws -> T {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: encodedData)
    }

    static func encode<T: Encodable>(_ model: T) throws -> Data? {
        let encoder = JSONEncoder()
        return try encoder.encode(model)
    }
}
