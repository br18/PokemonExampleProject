//
//  File.swift
//  
//
//  Created by Ben on 13/01/2023.
//

import Foundation
import XCTest

public func XCTAssertThrowsErrorAsync<T>(_ expression: @autoclosure () async throws -> T,
                                      _ message: String,
                                         _ errorBlock: (Error) -> Void = { _ in },
                                         file: StaticString = #filePath,
                                         line: UInt = #line) async {
    do {
        _ = try await expression()
        XCTFail(message)
    } catch {
        errorBlock(error)
    }
}

