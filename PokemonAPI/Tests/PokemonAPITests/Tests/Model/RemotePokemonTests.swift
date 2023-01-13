//
//  RemotePokemonTests.swift
//  
//
//  Created by Ben on 13/01/2023.
//

import XCTest
@testable import PokemonAPI

final class RemotePokemonTests: XCTestCase {

    private let validURL = "https://pokeapi.co/api/v2/ability/?limit=20&offset=20"

    func test_decodePokemonSprites_givenInvalidJSON_throwsError() {
        let data = Data.invalidJSON()
        XCTAssertThrowsError(try data.decode() as RemotePokemon)
    }

    func test_decodePokemonSprites_givenRandomJSON_throwsError() {
        let data = Data.randomJSON()
        XCTAssertThrowsError(try data.decode() as RemotePokemon)
    }

    func test_decodePokemonSprites_givenValidDataWithInvalidImageURL_throwsError() throws {
        let data = validDataWithNoTypes(name: "", height: 0, weight: 0, imageURL: "$%^3knrnx")
        XCTAssertThrowsError(try data.decode() as RemotePokemon)
    }

    func test_decodePokemonSprites_givenValidDataWithNoTypes_populatesData() throws {
        let name = "Bulbasaur"
        let height = 56
        let weight = 546
        let data = validDataWithNoTypes(name: name, height: height, weight: weight, imageURL: validURL)

        let result: RemotePokemon = try data.decode()

        XCTAssertEqual(result.name, name)
        XCTAssertEqual(result.heightInDecimeters, height)
        XCTAssertEqual(result.weightInHectograms, weight)
        XCTAssertEqual(result.sprites.frontDefault.absoluteString, validURL)
        XCTAssertEqual(result.types.count, 0)
    }

    func test_decodePokemonSprites_givenValidDataWithTypes_populatesData() throws {
        let name = "Bulbasaur"
        let height = 56
        let weight = 546
        let type1 = NamedAPIResource(name: "Hello", url: URL.any())
        let type2 = NamedAPIResource(name: "Fizz", url: URL(string: "https://pokeapi.co")!)
        let data = validDataWithTypes(name: name, height: height, weight: weight, imageURL: validURL, type1: type1, type2: type2)

        let result: RemotePokemon = try data.decode()

        XCTAssertEqual(result.name, name)
        XCTAssertEqual(result.heightInDecimeters, height)
        XCTAssertEqual(result.weightInHectograms, weight)
        XCTAssertEqual(result.sprites.frontDefault.absoluteString, validURL)
        XCTAssertEqual(result.types.count, 2)
        XCTAssertEqual(result.types.first?.type, type1)
        XCTAssertEqual(result.types.last?.type, type2)
    }



    private func validDataWithTypes(name: String,
                                    height: Int,
                                    weight: Int,
                                    imageURL: String,
                                    type1: NamedAPIResource,
                                    type2: NamedAPIResource) -> Data {
        Data("""
        {
        "name":"\(name)",
        "height": \(height),
        "weight": \(weight),
        "sprites": {
            "front_default": "\(imageURL)"
        },
        "types": [
                {
                    "type": {
                              "name" : "\(type1.name)",
                              "url": "\(type1.url)"
                            }
                },
                {
                    "type": {
                              "name" : "\(type2.name)",
                              "url": "\(type2.url)"
                            }
                }
        ]
        }
        """.utf8)
    }

    private func validDataWithNoTypes(name: String, height: Int, weight: Int, imageURL: String) -> Data {
        Data("""
        {
        "name":"\(name)",
        "height": \(height),
        "weight": \(weight),
        "sprites": {
            "front_default": "\(imageURL)"
        },
        "types": []
        }
        """.utf8)
    }
}

extension NamedAPIResource: Equatable {
    public static func == (lhs: NamedAPIResource, rhs: NamedAPIResource) -> Bool {
        lhs.name == rhs.name && lhs.url == rhs.url
    }
}
