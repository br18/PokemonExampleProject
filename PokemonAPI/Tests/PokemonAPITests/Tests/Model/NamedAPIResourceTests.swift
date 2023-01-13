//
//  NamedAPIResourceTests.swift
//  
//
//  Created by Ben on 13/01/2023.
//

import XCTest
@testable import PokemonAPI

final class NamedAPIResourceTests: XCTestCase {

    func test_decodeNamedAPIResource_givenInvalidJSON_throwsError() {
        let data = Data.invalidJSON()
        XCTAssertThrowsError(try data.decode() as NamedAPIResource)
    }


    func test_decodeNamedAPIResource_givenRandomJSON_throwsError() {
        let data = Data.randomJSON()
        XCTAssertThrowsError(try data.decode() as NamedAPIResource)
    }

    func test_decodeNamedAPIResource_givenValidData_decodesToObjectWithDataValues() throws {
        let name = "Hello"
        let url = "World"
        let data = validData(name: name, url: url)

        let result: NamedAPIResource = try data.decode()

        XCTAssertEqual(result.name, name)
        XCTAssertEqual(result.url.absoluteString, url)
    }

    private func validData(name: String, url: String) -> Data {
        Data("""
        {
          "name" : "\(name)",
          "url": "\(url)"
        }
        """.utf8)
    }

}
