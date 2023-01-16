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
    typealias CreateTask = (@escaping () async -> Void) -> Void

    var statePublisher: AnyPublisher<PokemonListViewState, Never> { $state.eraseToAnyPublisher() }
    var stateValue: PokemonListViewState { state }

    @Published private var state: PokemonListViewState

    private let pokemonRepository: PokemonRepository
    private let createTask: CreateTask
    private let viewDetails: (Int) -> Void
    private let pageSize: Int

    private var initialFetchStarted = false
    private var reachedEndOfPokemon = false

    init(pageSize: Int = 10,
         pokemonRepository: PokemonRepository,
         viewDetails: @escaping (Int) -> Void,
         createTask: @escaping CreateTask = { closure in Task { await closure() } } ) {
        state = PokemonListViewState(dataFetchState: .loading, items: [])
        self.pageSize = pageSize
        self.pokemonRepository = pokemonRepository
        self.createTask = createTask
        self.viewDetails = viewDetails
    }

    func perform(_ action: PokemonListViewAction) {
        switch action {
        case .loadPokemon:
            if shouldLoadPokemon {
                loadPokemon()
            }
        case .viewDetails(let id):
           viewDetails(id)
        }
    }


    private func loadPokemon() {
        if !initialFetchStarted {
            initialFetchStarted = true
        }

        state = PokemonListViewState(dataFetchState: .loading, items: state.items)

        createTask { [weak self] in
            guard let self else { return }
            let itemsBeforeLoad = self.state.items
            do {
                let pokemonResult = try await self.pokemonRepository.fetchPokemon(offset: itemsBeforeLoad.count,
                                                                                  limit: self.pageSize)
                let pokemonListItems = pokemonResult.pokemon.map { $0.toListItem() }
                let newItems = itemsBeforeLoad + pokemonListItems
                self.state = PokemonListViewState(dataFetchState: .loaded, items: newItems)
                self.reachedEndOfPokemon = newItems.count >= pokemonResult.totalCount
            } catch {
                self.state = PokemonListViewState(dataFetchState: .error, items: itemsBeforeLoad)
            }
        }
    }

    private var shouldLoadPokemon: Bool {
        if reachedEndOfPokemon {
            return false
        }
        let currentlyLoadingPokemon = initialFetchStarted && state.dataFetchState == .loading
        return !currentlyLoadingPokemon
    }
    
}

private extension Pokemon {
    func toListItem() -> PokemonListViewItem {
        PokemonListViewItem(id: id, name: name)
    }
}
