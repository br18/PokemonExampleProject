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

    func test_decode_givenValidDataWithInvalidURL_throwsError() throws {
        let name = "Hello"
        let url = "#%#^fw"
        let data = validData(name: name, url: url)

        XCTAssertThrowsError(try data.decode() as PokemonType)
    }

    func test_decode_givenValidDataWithValidURL_decodesToObjectWithDataValues() throws {
        let name = "Hello"
        let url = "https://pokeapi.co/api/v2/pokemon/6"
        let data = validData(name: name, url: url)

        let result: PokemonType = try data.decode()

        XCTAssertEqual(result.type.name, name)
        XCTAssertEqual(result.type.url.absoluteString, url)
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
