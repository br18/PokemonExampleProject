//
//  PokemonAPIClientTests.swift
//  
//
//  Created by Ben on 13/01/2023.
//

import XCTest
import PokemonDomain
@testable import PokemonAPI

final class PokemonAPIClientTests: XCTestCase {

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

    func test_fetchPokemonList_whenHTTPClientReturnsValidResponseWithURLEndingInInt_returnsMappedResponseToPokemonWithURLEndingsAsIds() async throws {
        let id1 = 156
        let id2 = 221
        let resourceListResults = [NamedAPIResource(name: "bulbasaur",url: URL.pokemonURL(id: String(id1))),
                                   NamedAPIResource(name: "ivysaur", url: URL.pokemonURL(id: String(id2)))]

        let totalCount = 2432
        let resourceList = NamedAPIResourceList(count: totalCount,
                                                results: resourceListResults)

        let httpResult: Result<NamedAPIResourceList, Error> = .success(resourceList)
        let httpClient = StubHTTPClient(stubbedGetResult: httpResult)

        let sut = createSut(responseType: NamedAPIResourceList.self, httpClient: httpClient)

        let result = try await sut.fetchPokemonList(limit: 5)

        XCTAssertEqual(result.totalCount, totalCount)
        XCTAssertEqual(result.pokemon.count, 2)
        XCTAssertEqual(result.pokemon.first?.id, id1)
        XCTAssertEqual(result.pokemon.first?.name, resourceListResults.first?.name)
        XCTAssertEqual(result.pokemon.last?.id, id2)
        XCTAssertEqual(result.pokemon.last?.name, resourceListResults.last?.name)
    }

    func test_fetchPokemonList_whenHTTPClientReturnsValidResponseWithURLThatHasNoPathComponents_throwsError() async {
        let resourceListResults = [NamedAPIResource(name: "bulbasaur", url: URL(string: "https://")!)]
        let resourceList = NamedAPIResourceList(count: 2,
                                                results: resourceListResults)

        let httpResult: Result<NamedAPIResourceList, Error> = .success(resourceList)
        let httpClient = StubHTTPClient(stubbedGetResult: httpResult)

        let sut = createSut(responseType: NamedAPIResourceList.self, httpClient: httpClient)


        await XCTAssertThrowsErrorAsync(_ = try await sut.fetchPokemonList(limit: 5), "Fetch pokemon list")
    }


    func test_fetchPokemonList_whenHTTPClientReturnsValidResponseWithURLEndingInString_throwsError() async {
        let resourceListResults = [NamedAPIResource(name: "bulbasaur", url: URL.pokemonURL(id: "Hello"))]
        let resourceList = NamedAPIResourceList(count: 2,
                                                results: resourceListResults)

        let httpResult: Result<NamedAPIResourceList, Error> = .success(resourceList)
        let httpClient = StubHTTPClient(stubbedGetResult: httpResult)

        let sut = createSut(responseType: NamedAPIResourceList.self, httpClient: httpClient)


        await XCTAssertThrowsErrorAsync(_ = try await sut.fetchPokemonList(limit: 5), "Fetch pokemon list")
    }

    func test_fetchPokemonDetails_whenHTTPClientThrowsError_throwsError() async {
        let httpResult: Result<RemotePokemon, Error> = .failure(MockError.mock1)
        let httpClient = StubHTTPClient(stubbedGetResult: httpResult)

        let sut = createSut(responseType: RemotePokemon.self, httpClient: httpClient)

        await XCTAssertThrowsErrorAsync(try await sut.fetchPokemonDetails(id: 0), "Fetch pokemon details")
    }

    func test_fetchPokemonDetails_givenId_requestsPokemonDetailsURLWithId() async {
        let id1 = 64
        let id2 = 654
        let httpResult: Result<RemotePokemon, Error> = .failure(MockError.mock1)
        let httpClient = StubHTTPClient(stubbedGetResult: httpResult)

        let sut = createSut(responseType: RemotePokemon.self, httpClient: httpClient)

        _ = try? await sut.fetchPokemonDetails(id: id1)
        _ = try? await sut.fetchPokemonDetails(id: id2)

        let urlComponents1 = URLComponents(url: httpClient.getParametersList.first!, resolvingAgainstBaseURL: true)
        let urlComponents2 = URLComponents(url: httpClient.getParametersList.last!, resolvingAgainstBaseURL: true)

        XCTAssertEqual(urlComponents1, URLComponents(string: "\(fetchPokemonListBaseURL)/\(id1)"))
        XCTAssertEqual(urlComponents2, URLComponents(string: "\(fetchPokemonListBaseURL)/\(id2)"))
    }

    func test_fetchPokemonDetails_whenHTTPClientIsSuccessfulWithRemotePokemon_mapsPokemonToDetails() async throws {

        let types = ["grass", "water"]
        let remotePokemon = RemotePokemon(name: "bulbasaur",
                                          heightInDecimeters: 56,
                                          weightInHectograms: 43,
                                          sprites: PokemonSprites(frontDefault: URL.any()),
                                          types: types.map { makePokemonType(name: $0, url: URL.any()) })

        let httpResult: Result<RemotePokemon, Error> = .success(remotePokemon)
        let httpClient = StubHTTPClient(stubbedGetResult: httpResult)

        let sut = createSut(responseType: RemotePokemon.self, httpClient: httpClient)

        let result = try await sut.fetchPokemonDetails(id: 34)

        XCTAssertEqual(result.name, remotePokemon.name)
        XCTAssertEqual(result.weightInHectograms, remotePokemon.weightInHectograms)
        XCTAssertEqual(result.heightInDecimeters, remotePokemon.heightInDecimeters)
        XCTAssertEqual(result.image, remotePokemon.sprites.frontDefault)
        XCTAssertEqual(result.types, types)
    }


    private func makePokemonType(name: String, url: URL) -> PokemonType {
        PokemonType(type: NamedAPIResource(name: name, url: url))
    }

    private func createSut<U: Decodable>(responseType: U.Type,
                                         httpClient: HTTPClient = StubHTTPClient(stubbedGetResult: Result<U, Error>.failure(MockError.mock1))) -> PokemonAPIClient {
        let sut = PokemonAPIClient(httpClient: httpClient)
        trackForMemoryLeaks(sut)
        return sut
    }
}

private extension URL {
    static func pokemonURL(id: String) -> URL {
        let urlString = "https://pokeapi.co/api/v2/pokemon/\(id)/"
        return URL(string: urlString)!
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

