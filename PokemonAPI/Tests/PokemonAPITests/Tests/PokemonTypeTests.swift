//
//  PokemonTypeTests.swift
//  
//
//  Created by Ben on 13/01/2023.
//

import XCTest
@testable import PokemonAPI

final class PokemonTypeTests: XCTestCase {

    func test_decode_givenInvalidJSON_throwsError() {
        let data = Data.invalidJSON()
        XCTAssertThrowsError(try data.decode() as PokemonType)
    }


    func test_decode_givenRandomJSON_throwsError() {
        let data = Data.randomJSON()
        XCTAssertThrowsError(try data.decode() as PokemonType)
    }

    func test_decode_givenValidData_decodesToObjectWithDataValues() throws {
        let name = "Hello"
        let url = "World"
        let data = validData(name: name, url: url)

        let result: PokemonType = try data.decode()

        XCTAssertEqual(result.type.name, name)
        XCTAssertEqual(result.type.url, url)
    }

    private func validData(name: String, url: String) -> Data {
        Data("""
        {
            "type": {
                      "name" : "\(name)",
                      "url": "\(url)"
                    }
        }
        """.utf8)

    }

}
