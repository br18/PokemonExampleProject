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

    public init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }

    public func fetchPokemonList(offset: Int = 0, limit: Int) async throws -> [Pokemon] {
        []
    }

    public func fetchPokemonDetails(id: String) async throws -> PokemonDetails {
        PokemonDetails(name: "", image: URL.any(), heightInDecimeters: 0, weightInHectograms: 0, types: [])
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

}

class StubHTTPClient<U: Decodable>: HTTPClient {
    var getParametersList = [URL]()
    var stubbedGetResult: Result<U, Error> = .failure(MockError.mock1)

    func get<T>(url: URL) async throws -> T {
        getParametersList.append(url)
        return try stubbedGetResult.get() as! T
    }
}

