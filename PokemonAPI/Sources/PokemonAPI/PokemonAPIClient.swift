//
//  PokemonAPIClient.swift
//  
//
//  Created by Ben on 13/01/2023.
//

import Foundation
import PokemonDomain

public struct PokemonListResponse {
    public let pokemon: [Pokemon]
    public let totalCount: Int

    init(pokemon: [Pokemon], totalCount: Int) {
        self.pokemon = pokemon
        self.totalCount = totalCount
    }
}

public class PokemonAPIClient {
    private let httpClient: HTTPClient

    private let baseURLString = "https://pokeapi.co/api/v2"

    public init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }

    public func fetchPokemonList(offset: Int = 0, limit: Int) async throws -> PokemonListResponse {
        let resourceList: NamedAPIResourceList = try await httpClient.get(url: createFetchPokemonListURL(offset: offset, limit: limit))
        return try resourceList.toPokemonList()
    }

    public func fetchPokemonDetails(id: Int) async throws -> PokemonDetails {
        let remotePokemon: RemotePokemon = try await httpClient.get(url: createPokemonDetailsURL(id: id))
        return remotePokemon.toPokemonDetails()
    }

    private func createPokemonDetailsURL(id: Int) -> URL {
        var (components, path) = baseURLDetails
        components.path = path + "/pokemon/\(id)"
        return components.url!
    }

    private func createFetchPokemonListURL(offset: Int, limit: Int) -> URL {
        var (components, path) = baseURLDetails
        components.path = path + "/pokemon"
        components.queryItems = [
            URLQueryItem(name: "offset", value: String(offset)),
            URLQueryItem(name: "limit", value: String(limit))
        ]
        return components.url!
    }

    private var baseURLDetails: (components: URLComponents, path: String) {
        let baseURL = URL(string: baseURLString)!
        var components = URLComponents()
        components.scheme = baseURL.scheme
        components.host = baseURL.host
        return (components, baseURL.path)
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

    func toPokemonList() throws -> PokemonListResponse {
        let pokemon = try results.map { resource in
            guard let lastPathComponent = resource.url.pathComponents.last else {
                throw Error.noPathComponents
            }

            guard let id = Int(lastPathComponent) else {
                throw Error.lastPathComponentNotInt
            }

            return Pokemon(id: id, name: resource.name)
        }

        return PokemonListResponse(pokemon: pokemon, totalCount: count)
    }
}
