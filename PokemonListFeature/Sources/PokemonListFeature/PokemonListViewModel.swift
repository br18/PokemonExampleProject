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
    typealias CreateTask = (@escaping () async -> Void) -> Task<(), Never>

    var statePublisher: AnyPublisher<PokemonListViewState, Never> { $state.eraseToAnyPublisher() }
    var stateValue: PokemonListViewState { state }

    @Published private var state: PokemonListViewState

    private let pokemonRepository: PokemonRepository
    private let createTask: CreateTask
    private let viewDetails: (Int) -> Void

    init(pokemonRepository: PokemonRepository,
         viewDetails: @escaping (Int) -> Void,
         createTask: @escaping CreateTask = { closure in Task { await closure() } } ) {
        state = PokemonListViewState(dataFetchState: .loading, items: [])
        self.pokemonRepository = pokemonRepository
        self.createTask = createTask
        self.viewDetails = viewDetails
    }

    func perform(_ action: PokemonListViewAction) {
        switch action {
        case .loadPokemon:
            break
        case .viewDetails(let id):
           viewDetails(id)
        }
    }

    
}
