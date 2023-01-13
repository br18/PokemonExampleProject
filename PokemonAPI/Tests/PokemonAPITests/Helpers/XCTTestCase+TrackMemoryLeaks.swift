//
//  File.swift
//  
//
//  Created by Ben on 13/01/2023.
//

import Foundation
import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(_ object: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak object] in
            XCTAssertNil(object, "Object has not been deallocated, this could be a memory leak.", file: file, line: line)
        }
    }
}
