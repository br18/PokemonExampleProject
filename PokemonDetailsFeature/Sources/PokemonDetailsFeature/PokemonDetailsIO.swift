//
//  File.swift
//  
//
//  Created by Ben on 16/01/2023.
//

import Foundation

// MARK: - View Input - State

struct PokemonLoadedDetailsViewState {
    let name: String
    let imageURL: URL
    let weight: String
    let height: String
    let types: [String]
}

enum PokemonDetailsViewState {
    case loading
    case error
    case loaded(details: PokemonLoadedDetailsViewState)
}

// MARK: - View Output - Actions

enum PokemonDetailsViewAction {
    case loadData
}
