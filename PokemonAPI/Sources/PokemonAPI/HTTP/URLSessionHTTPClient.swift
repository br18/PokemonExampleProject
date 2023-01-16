//
//  URLSessionHTTPClient.swift
//  
//
//  Created by Ben on 13/01/2023.
//

import Foundation

public protocol URLSessionURLFetching {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

public class URLSessionHTTPClient: HTTPClient {
    private let urlSession: URLSessionURLFetching

    public init(urlSession: URLSessionURLFetching) {
        self.urlSession = urlSession
    }

    public func get<T: Decodable>(url: URL) async throws -> T {
        let data = try await urlSession.data(from: url).0
        return try JSONDecoder().decode(T.self, from: data)
    }
}
