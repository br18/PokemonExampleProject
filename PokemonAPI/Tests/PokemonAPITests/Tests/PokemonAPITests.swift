//
//  PokemonAPITests.swift
//  
//
//  Created by Ben on 13/01/2023.
//

import XCTest
@testable import PokemonAPI

public struct Pokemon {
    let id: Int
    let name: String
}

public struct PokemonDetails {
    let name: String
    let image: URL
    let heightInDecimeters: Int
    let weightInHectograms: Int
    let types: [String]
}

public class PokemonAPI {
    private let httpClient: HTTPClient

    private let baseURLString = "https://pokeapi.co/api/v2"

    public init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }

    public func fetchPokemonList(offset: Int = 0, limit: Int) async throws -> [Pokemon] {
        _ = try await httpClient.get(url: createFetchPokemonListURL(offset: offset, limit: limit)) as NamedAPIResourceList
        return []
    }

    public func fetchPokemonDetails(id: String) async throws -> PokemonDetails {
        PokemonDetails(name: "", image: URL.any(), heightInDecimeters: 0, weightInHectograms: 0, types: [])
    }

    private func createFetchPokemonListURL(offset: Int, limit: Int) -> URL {
        let baseURL = URL(string: baseURLString)!
        var components = URLComponents()
        components.scheme = baseURL.scheme
        components.host = baseURL.host
        components.path = baseURL.path + "/pokemon"
        components.queryItems = [
            URLQueryItem(name: "offset", value: String(offset)),
            URLQueryItem(name: "limit", value: String(limit))
        ]
        return components.url!
    }
}

private extension RemotePokemon {
    func toPokemonDetails() -> PokemonDetails {
        PokemonDetails(name: name,
                       image: sprites.frontDefault,
                       heightInDecimeters: heightInDecimeters,
                       weightInHectograms: weightInHectograms,
                       types: types.map { $0.type.name })
    }
}

private extension NamedAPIResourceList {
    private enum Error: Swift.Error {
        case noPathComponents
        case lastPathComponentNotInt
    }

    func toPokemonList() throws -> [Pokemon] {
        try results.map { resource in
            guard let lastPathComponent = resource.url.pathComponents.last else {
                throw Error.noPathComponents
            }

            guard let id = Int(lastPathComponent) else {
                throw Error.lastPathComponentNotInt
            }

            return Pokemon(id: id, name: resource.name)
        }
    }
}

final class PokemonAPITests: XCTestCase {

    private let fetchPokemonListBaseURL = "https://pokeapi.co/api/v2/pokemon"

    func test_fetchPokemonList_whenHTTPClientThrowsError_throwsError() async {
        let httpResult: Result<NamedAPIResourceList, Error> = .failure(MockError.mock1)
        let httpClient = StubHTTPClient(stubbedGetResult: httpResult)

        let sut = createSut(responseType: NamedAPIResourceList.self, httpClient: httpClient)

        await XCTAssertThrowsErrorAsync(try await sut.fetchPokemonList(offset: 5, limit: 5), "Fetch pokemon list")
    }

    func test_fetchPokemonList_givenOffsetAndLimit_requestsGetPokemonListURLWithOffsetAndLimit() async {
        let offset1 = 353
        let limit1 = 24
        let offset2 = 3
        let limit2 = 44

        let httpResult: Result<NamedAPIResourceList, Error> = .failure(MockError.mock1)
        let httpClient = StubHTTPClient(stubbedGetResult: httpResult)

        let sut = createSut(responseType: NamedAPIResourceList.self, httpClient: httpClient)

        _ = try? await sut.fetchPokemonList(offset: offset1, limit: limit1)
        _ = try? await sut.fetchPokemonList(offset: offset2, limit: limit2)

        XCTAssertEqual(httpClient.getParametersList.count, 2)

        let urlComponents1 = URLComponents(url: httpClient.getParametersList.first!, resolvingAgainstBaseURL: true)
        let urlComponents2 = URLComponents(url: httpClient.getParametersList.last!, resolvingAgainstBaseURL: true)

        XCTAssertEqual(urlComponents1, URLComponents(string: "\(fetchPokemonListBaseURL)?offset=\(offset1)&limit=\(limit1)"))
        XCTAssertEqual(urlComponents2, URLComponents(string: "\(fetchPokemonListBaseURL)?offset=\(offset2)&limit=\(limit2)"))
    }

    private func createSut<U: Decodable>(responseType: U.Type,
                                         httpClient: HTTPClient = StubHTTPClient(stubbedGetResult: Result<U, Error>.failure(MockError.mock1))) -> PokemonAPI {
        let sut = PokemonAPI(httpClient: httpClient)
        trackForMemoryLeaks(sut)
        return sut
    }
}

class StubHTTPClient<U: Decodable>: HTTPClient {

    init(stubbedGetResult: Result<U, Error>) {
        self.stubbedGetResult = stubbedGetResult
    }

    var getParametersList = [URL]()
    var stubbedGetResult: Result<U, Error>

    func get<T>(url: URL) async throws -> T {
        getParametersList.append(url)
        return try stubbedGetResult.get() as! T
    }
}

