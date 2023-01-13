//
//  PokemonSpritesTests.swift
//  
//
//  Created by Ben on 13/01/2023.
//

import XCTest
@testable import PokemonAPI

final class PokemonSpritesTests: XCTestCase {

    func test_decodePokemonSprites_givenInvalidJSON_throwsError() {
        let data = Data.invalidJSON()
        XCTAssertThrowsError(try data.decode() as PokemonSprites)
    }

    func test_decodePokemonSprites_givenRandomJSON_throwsError() {
        let data = Data.randomJSON()
        XCTAssertThrowsError(try data.decode() as PokemonSprites)
    }

    func test_decodePokemonSprites_givenValidDataWithInvalidURL_throwsError() {
        let frontDefaultURL = "htp&^24:fefnjw344^"
        let data = validData(frontDefaultURL: frontDefaultURL)
        XCTAssertThrowsError(try data.decode() as PokemonSprites)
    }

    func test_decodePokemonSprites_givenValidDataWithValidURL_decodesToObjectWithDataValues() throws {
        let frontDefaultURL = "https://pokeapi.co/api/v2/ability/?limit=20&offset=20"
        let data = validData(frontDefaultURL: frontDefaultURL)

        let result: PokemonSprites = try data.decode()

        XCTAssertEqual(result.frontDefault.absoluteString, frontDefaultURL)
    }

    private func validData(frontDefaultURL: String) -> Data {
        Data("""
        {
          "front_default": "\(frontDefaultURL)"
        }
        """.utf8)
    }
   

}
