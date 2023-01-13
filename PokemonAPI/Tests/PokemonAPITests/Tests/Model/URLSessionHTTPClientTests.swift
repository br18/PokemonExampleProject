//
//  URLSessionHTTPClientTests.swift
//  
//
//  Created by Ben on 13/01/2023.
//

import XCTest

protocol URLSessionURLFetching {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

class URLSessionHTTPClient {
    private let urlSession: URLSessionURLFetching

    init(urlSession: URLSessionURLFetching) {
        self.urlSession = urlSession
    }

    func get<T: Decodable>(url: URL) async throws -> T {
        _ = try await urlSession.data(from: url)
        throw MockError.mock1
    }
}

final class URLSessionHTTPClientTests: XCTestCase {

    func test_get_givenURL_requestsDataFromURL() async throws {
        let urlSession = StubURLSession()
        let sut = makeSUT(urlSession: urlSession)

        let url1 = URL.anyURL()
        let url2 = URL(string: "https://pokeapi.co")!

        _ = try? await sut.get(url: url1) as String
        _ = try? await sut.get(url: url2) as String

        XCTAssertEqual(urlSession.dataParametersList.count, 2)
        XCTAssertEqual(urlSession.dataParametersList.first, url1)
        XCTAssertEqual(urlSession.dataParametersList.last, url2)
    }

    private func makeSUT(urlSession: URLSessionURLFetching = StubURLSession()) -> URLSessionHTTPClient {
        return URLSessionHTTPClient(urlSession: urlSession)
    }
}

class StubURLSession: URLSessionURLFetching {
    var dataParametersList = [URL]()
    var dataError: Error?
    var stubbedResponse: (Data, URLResponse) = (Data(), URLResponse())
    func data(from url: URL) async throws -> (Data, URLResponse) {
        dataParametersList.append(url)
        if let dataError {
            throw dataError
        }
        return stubbedResponse
    }
}

private extension URL {
    static func anyURL() -> URL {
        URL(string: "https://google.com")!
    }
}
