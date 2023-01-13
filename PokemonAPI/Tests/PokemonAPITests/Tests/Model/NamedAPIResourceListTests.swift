//
//  NamedAPIResourceListTests.swift
//  
//
//  Created by Ben on 13/01/2023.
//

import XCTest
@testable import PokemonAPI

final class NamedAPIResourceListTests: XCTestCase {

    func test_decodeNamedAPIResourceList_givenInvalidJSON_throwsError() {
        let data = Data.invalidJSON()
        XCTAssertThrowsError(try data.decode() as NamedAPIResourceList)
    }


    func test_decodeNamedAPIResourceList_givenRandomJSON_throwsError() {
        let data = Data.randomJSON()
        XCTAssertThrowsError(try data.decode() as NamedAPIResourceList)
    }

    func test_decodeNamedAPIResourceList_givenEmptyResults_decodesToObjectWithEmptyAnd0Count() throws {
        let data = validDataWithoutResults()

        let result: NamedAPIResourceList = try data.decode()

        XCTAssertEqual(result.count, 0)
        XCTAssertTrue(result.results.isEmpty)
    }

    func test_decodeNamedAPIResourceList_givenCountAndResults_decodesToObjectWithCountAndResults() throws {
        let result1: NameAPIResourceResultData = ("Hello", "World")
        let result2: NameAPIResourceResultData = ("Fizz", "Buzz")


        let data = validDataWithResults(count: 2, result1: result1, result2: result2)

        let result: NamedAPIResourceList = try data.decode()

        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result.results.count, 2)
        assertEqual(resource: result.results.first, data: result1)
        assertEqual(resource: result.results.last, data: result2)
    }

    private func assertEqual(resource: NamedAPIResource?,
                             data: NameAPIResourceResultData,
                             file: StaticString = #filePath,
                             line: UInt = #line) {

        XCTAssertEqual(resource?.name, data.name)
        XCTAssertEqual(resource?.url, data.url)
    }

    typealias NameAPIResourceResultData = (name: String, url: String)

    private func validDataWithResults(count: Int,
                                      result1: NameAPIResourceResultData,
                                      result2: NameAPIResourceResultData) -> Data {
        Data("""
        {
          "count" : \(count),
          "results": [
                {
                  "name" : "\(result1.name)",
                  "url": "\(result1.url)"
                },
                {
                  "name" : "\(result2.name)",
                  "url": "\(result2.url)"
                }
        ]
        }
        """.utf8)
    }

    private func validDataWithoutResults() -> Data {
        Data("""
        {
          "count" : 0,
          "results": []
        }
        """.utf8)
    }
}
