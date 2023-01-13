//
//  Array+RangeTests.swift
//  
//
//  Created by Ben on 13/01/2023.
//

import XCTest
@testable import PokemonListFeature

final class Array_RangeTests: XCTestCase {

    private let array = ["1", "2", "3"]
    private let emptyArray = [String]()

    func test_containsInRange_givenIndexIsLessThanZero_returnsFalse() {
        let index = -1

        XCTAssertFalse(array.containsInRange(index))
        XCTAssertFalse(emptyArray.containsInRange(index))
    }

    func test_containsInRange_givenZeroIndexInEmptyArray_returnsFalse() {
        let index = 0
        XCTAssertFalse(emptyArray.containsInRange(index))
    }

    func test_containsInRange_givenZeroIndexInArrayWithItems_returnsTrue() {
        let index = 0
        XCTAssertTrue(array.containsInRange(index))
    }

    func test_containsInRange_givenIndexInArrayWithItems_returnsTrue() {
        let index = 2
        XCTAssertTrue(array.containsInRange(index))
    }

    func test_containsInRange_givenIndexAtCountInArrayWithItems_returnsFalse() {
        let index = array.count
        XCTAssertFalse(array.containsInRange(index))
    }

    func test_containsInRange_givenIndexBeyondCountInArrayWithItems_returnsFalse() {
        let index = array.count + 1
        XCTAssertFalse(array.containsInRange(index))
    }

}
