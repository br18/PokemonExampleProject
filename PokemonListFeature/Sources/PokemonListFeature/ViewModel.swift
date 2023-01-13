//
//  ViewModel.swift
//  MVIWithViewModelProtocol
//
//  Created by Ben on 13/01/2023.
//

import Foundation

protocol ViewModel: ObservableObject {
    associatedtype State
    associatedtype Action

    var state: State { get }
    func perform(_ action: Action)
}
