//
//  URLSessionHTTPClientTests.swift
//  
//
//  Created by Ben on 13/01/2023.
//

import XCTest
@testable import PokemonAPI

final class URLSessionHTTPClientTests: XCTestCase {

    func test_get_givenURL_requestsDataFromURL() async throws {
        let urlSession = StubURLSession()
        let sut = makeSUT(urlSession: urlSession)

        let url1 = URL.any()
        let url2 = URL(string: "https://pokeapi.co")!

        _ = try? await sut.get(url: url1) as String
        _ = try? await sut.get(url: url2) as String

        XCTAssertEqual(urlSession.dataParametersList.count, 2)
        XCTAssertEqual(urlSession.dataParametersList.first, url1)
        XCTAssertEqual(urlSession.dataParametersList.last, url2)
    }

    func test_get_givenDataInResponseIsNotJSONDecodable_throwsError() async {
        let urlSession = StubURLSession()
        urlSession.stubbedResponse = (Data.invalidJSON(), HTTPURLResponse.any())
        let sut = makeSUT(urlSession: urlSession)

        await XCTAssertThrowsErrorAsync(_ = try await sut.get(url: URL.any()) as RemoteObject, "Get from url")
    }

    func test_get_givenDataInResponseDoesNotDecodeToGivenType_throwsError() async {
        let urlSession = StubURLSession()
        urlSession.stubbedResponse = (Data.randomJSON(), HTTPURLResponse.any())
        let sut = makeSUT(urlSession: urlSession)

        await XCTAssertThrowsErrorAsync(_ = try await sut.get(url: URL.any()) as RemoteObject, "Get from url")
    }

    func test_get_givenDataInResponseDecodesToGivenType_returnsPopulatedResponse() async throws {
        let remoteObject = RemoteObject(id: 5, message: "Hello world!")
        let urlSession = StubURLSession()
        urlSession.stubbedResponse = (remoteObjectJSONData(remoteObject: remoteObject), HTTPURLResponse.any())
        let sut = makeSUT(urlSession: urlSession)

        let result: RemoteObject = try await sut.get(url: URL.any())

        XCTAssertEqual(result, remoteObject)
    }

    private func makeSUT(urlSession: URLSessionURLFetching = StubURLSession()) -> URLSessionHTTPClient {
        let sut = URLSessionHTTPClient(urlSession: urlSession)
        trackForMemoryLeaks(sut)
        return sut
    }

    private func remoteObjectJSONData(remoteObject: RemoteObject) -> Data {
        Data("""
        {
        "id": \(remoteObject.id),
        "message": "\(remoteObject.message)"
        }
        """.utf8)
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

struct RemoteObject: Decodable, Equatable {
    let id: Int
    let message: String
}

private extension URL {
    static func any() -> URL {
        URL(string: "https://google.com")!
    }
}

private extension URLResponse {
    static func any() -> URLResponse {
        URLResponse(url: URL.any(),
                    mimeType: nil,
                    expectedContentLength: 0,
                    textEncodingName: nil)
    }
}
