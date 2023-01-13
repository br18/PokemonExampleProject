//
//  ViewModel.swift
//  MVIWithViewModelProtocol
//
//  Created by Ben on 13/01/2023.
//

import Foundation
import Combine

protocol ViewModel {
    associatedtype State
    associatedtype Action

    var statePublisher: AnyPublisher<State, Never> { get }
    var stateValue: State { get }

    func perform(_ action: Action)
}
