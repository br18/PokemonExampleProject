//
//  PokemonDetailsViewModel.swift
//  
//
//  Created by Ben on 17/01/2023.
//

import Foundation
import SharedUI
import Combine
import PokemonDomain

protocol PokemonDetailsRepository {
    func fetchPokemonDetails(id: Int) async throws -> PokemonDetails
}

class PokemonDetailsViewModel: ViewModel {
    public typealias CreateTask = (@escaping () async -> Void) -> Void
    
    public var statePublisher: AnyPublisher<PokemonDetailsViewState, Never> { $state.eraseToAnyPublisher() }
    public var stateValue: PokemonDetailsViewState { state }

    private let pokemonId: Int
    private let repository: PokemonDetailsRepository
    private let createTask: CreateTask

    @Published private var state: PokemonDetailsViewState

    init(pokemonId: Int,
         repository: PokemonDetailsRepository,
         createTask: @escaping CreateTask = { closure in Task { await closure() } } ) {
        self.pokemonId = pokemonId
        self.state = .loading
        self.repository = repository
        self.createTask = createTask
    }

    func perform(_ action: PokemonDetailsViewAction) {
        switch action {
        case .loadData:
            loadData()
        }
    }

    private func loadData() {
        createTask { [weak self] in
            guard let self else { return }
            do {
                _ = try await self.repository.fetchPokemonDetails(id: self.pokemonId)
            } catch {
                self.state = .error
            }
        }
    }
}
