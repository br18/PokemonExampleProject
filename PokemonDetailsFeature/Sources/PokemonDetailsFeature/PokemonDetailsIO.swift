//
//  File.swift
//  
//
//  Created by Ben on 16/01/2023.
//

import Foundation

// MARK: - View Input - State

public struct PokemonLoadedDetailsViewState {
    let name: String
    let imageURL: URL
    let weight: String
    let height: String
    let types: String

    init(name: String, imageURL: URL, weight: String, height: String, types: String) {
        self.name = name
        self.imageURL = imageURL
        self.weight = weight
        self.height = height
        self.types = types
    }
}

public enum PokemonDetailsViewState {
    case loading
    case error
    case loaded(details: PokemonLoadedDetailsViewState)
}

// MARK: - View Output - Actions

public enum PokemonDetailsViewAction {
    case loadData
}
