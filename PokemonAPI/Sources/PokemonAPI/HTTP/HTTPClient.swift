//
//  HTTPClient.swift
//  
//
//  Created by Ben on 13/01/2023.
//

import Foundation

public protocol HTTPClient {
    func get<T: Decodable>(url: URL) async throws -> T
}
