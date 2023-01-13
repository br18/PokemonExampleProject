//
//  Data+DecodableTestHelpers.swift
//  
//
//  Created by Ben on 13/01/2023.
//

import Foundation

extension Data {
    static func randomJSON() -> Data {
        Data("""
        {
          "kfnkewnf" : "aflmlemlsdmf",
        }
        """.utf8)
    }

    static func invalidJSON() -> Data {
        Data("""
        {sf;ma,34[]32ojr45km
        """.utf8)
    }

    @discardableResult func decode<T: Decodable>() throws -> T {
        return try JSONDecoder().decode(T.self, from: self)
    }
}
