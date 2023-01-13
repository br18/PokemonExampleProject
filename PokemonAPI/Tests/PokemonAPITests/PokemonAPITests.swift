import XCTest
@testable import PokemonAPI

final class PokemonAPITests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(PokemonAPI().text, "Hello, World!")
    }
}
