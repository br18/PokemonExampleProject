//
//  File.swift
//  
//
//  Created by Ben on 13/01/2023.
//

import Foundation
@testable import PokemonListFeature

class StubViewModel<State, Action>: ViewModel {
    var state: State {
        willSet {
            objectWillChange.send()
        }
    }

    init(initialState: State) {
        state = initialState
    }

    var performActionParameters = [Action]()
    func perform(_ action: Action) {
        performActionParameters.append(action)
    }
}
