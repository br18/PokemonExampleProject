//
//  Adapters.swift
//  Pokemon
//
//  Created by Ben on 16/01/2023.
//

import Foundation
import PokemonDomain
import PokemonListFeature
import PokemonAPI

extension PokemonAPIClient: PokemonRepository {
    public func fetchPokemon(offset: Int, limit: Int) async throws -> (pokemon: [PokemonDomain.Pokemon], totalCount: Int) {
        let result = try await fetchPokemonList(offset: offset, limit: limit)
        return (pokemon: result.pokemon, totalCount: result.totalCount)
    }
}

extension URLSession: URLSessionURLFetching {}
