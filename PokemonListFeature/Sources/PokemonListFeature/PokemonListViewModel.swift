//
//  PokemonListViewModel.swift
//  
//
//  Created by Ben on 15/01/2023.
//

import Foundation
import Combine
import PokemonDomain

protocol PokemonRepository {
    func fetchPokemon(offset: Int, limit: Int) async throws -> (pokemon: [Pokemon], totalCount: Int)
}

class PokemonListViewModel: ViewModel {
    var statePublisher: AnyPublisher<PokemonListViewState, Never> { $state.eraseToAnyPublisher() }
    var stateValue: PokemonListViewState { state }

    @Published private var state: PokemonListViewState

    private let pokemonRepository: PokemonRepository

    init(pokemonRepository: PokemonRepository) {
        state = PokemonListViewState(dataFetchState: .loading, items: [])
        self.pokemonRepository = pokemonRepository
    }

    func perform(_ action: PokemonListViewAction) {
        //
    }
}
