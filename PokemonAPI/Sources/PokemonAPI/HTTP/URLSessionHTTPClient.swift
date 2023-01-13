//
//  URLSessionHTTPClient.swift
//  
//
//  Created by Ben on 13/01/2023.
//

import Foundation

protocol URLSessionURLFetching {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionURLFetching {}

class URLSessionHTTPClient {
    private let urlSession: URLSessionURLFetching

    init(urlSession: URLSessionURLFetching) {
        self.urlSession = urlSession
    }

    func get<T: Decodable>(url: URL) async throws -> T {
        let data = try await urlSession.data(from: url).0
        return try JSONDecoder().decode(T.self, from: data)
    }
}
