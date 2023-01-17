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

public protocol PokemonDetailsRepository {
    func fetchPokemonDetails(id: Int) async throws -> PokemonDetails
}

public class PokemonDetailsViewModel: ViewModel {
    public typealias CreateTask = (@escaping () async -> Void) -> Void
    
    public var statePublisher: AnyPublisher<PokemonDetailsViewState, Never> { $state.eraseToAnyPublisher() }
    public var stateValue: PokemonDetailsViewState { state }

    private let pokemonId: Int
    private let repository: PokemonDetailsRepository
    private let createTask: CreateTask

    private var loadCalledBefore = false

    @Published private var state: PokemonDetailsViewState

    public init(pokemonId: Int,
         repository: PokemonDetailsRepository,
         createTask: @escaping CreateTask = { closure in Task { await closure() } } ) {
        self.pokemonId = pokemonId
        self.state = .loading
        self.repository = repository
        self.createTask = createTask
    }

    public func perform(_ action: PokemonDetailsViewAction) {
        switch action {
        case .loadData:
            if shouldLoadData {
                loadData()
            }
        }
    }

    private func loadData() {
        loadCalledBefore = true
        state = .loading

        createTask { [weak self] in
            guard let self else { return }
            do {
                let result = try await self.repository.fetchPokemonDetails(id: self.pokemonId)
                self.setStateToLoaded(details: result)
            } catch {
                self.state = .error
            }
        }
    }

    private func setStateToLoaded(details: PokemonDetails) {
        let types = details.types.map { $0.capitalized }.joined(separator: ", ")
        let weightInKg = Float(details.weightInHectograms)*0.1
        let weightText = "\(weightInKg)kg"

        let heightInMeters = Float(details.heightInDecimeters)*0.1
        let heightText = "\(heightInMeters)m"

        let loadedDetailsViewState = PokemonLoadedDetailsViewState(name: details.name.capitalized,
                                                                   imageURL: details.image,
                                                                   weight: weightText,
                                                                   height: heightText,
                                                                   types: types)

        state = .loaded(details: loadedDetailsViewState)
    }

    private var shouldLoadData: Bool {
        if case .loading = state {
            return !loadCalledBefore
        }
        return true
    }
}
