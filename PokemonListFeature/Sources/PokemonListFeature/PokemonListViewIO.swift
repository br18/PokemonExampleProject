//
//  PokemonListViewIO.swift
//  
//
//  Created by Ben on 13/01/2023.
//

import Foundation

// MARK: - View Input - State

public struct PokemonListViewItem {
    var id: Int
    var name: String
}

public enum PokemonListViewDataFetchState {
    case loading
    case loaded
    case error
}

public struct PokemonListViewState {
    var dataFetchState: PokemonListViewDataFetchState
    var items: [PokemonListViewItem]
}

// MARK: - View Output - Actions

public enum PokemonListViewAction {
    case loadPokemon
    case viewDetails(id: Int)
}
