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

    private let repository: PokemonDetailsRepository
    private let createTask: CreateTask

    @Published private var state: PokemonDetailsViewState

    init(repository: PokemonDetailsRepository,
         createTask: @escaping CreateTask = { closure in Task { await closure() } } ) {
        self.state = .loading
        self.repository = repository
        self.createTask = createTask
    }

    func perform(_ action: PokemonDetailsViewAction) {

    }
}
