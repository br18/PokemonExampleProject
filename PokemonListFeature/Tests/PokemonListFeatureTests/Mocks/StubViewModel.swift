//
//  File.swift
//  
//
//  Created by Ben on 13/01/2023.
//

import Foundation
import Combine
@testable import PokemonListFeature

class StubViewModel<State, Action>: ViewModel {
    var statePublisher: AnyPublisher<State, Never> { $state.eraseToAnyPublisher() }
    var stateValue: State { state }

    @Published var state: State

    init(initialState: State) {
        state = initialState
    }

    var performActionParameters = [Action]()
    func perform(_ action: Action) {
        performActionParameters.append(action)
    }
}
