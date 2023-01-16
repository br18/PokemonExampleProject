//
//  File.swift
//  
//
//  Created by Ben on 13/01/2023.
//

import Foundation
import Combine
import SharedUI

public class StubViewModel<State, Action>: ViewModel {
    public var statePublisher: AnyPublisher<State, Never> { $state.eraseToAnyPublisher() }
    public var stateValue: State { state }

    @Published public var state: State

    public init(initialState: State) {
        state = initialState
    }

    public var performActionParameters = [Action]()
    public func perform(_ action: Action) {
        performActionParameters.append(action)
    }
}
