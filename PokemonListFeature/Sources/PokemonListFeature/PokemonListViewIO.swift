//
//  PokemonListViewIO.swift
//  
//
//  Created by Ben on 13/01/2023.
//

import Foundation

// MARK: - View Input - State

struct PokemonListViewItem {
    var id: Int
    var name: String
}

enum PokemonListViewDataFetchState {
    case loading
    case loaded
    case error
}

struct PokemonListViewState {
    var dataFetchState: PokemonListViewDataFetchState
    var items: [PokemonListViewItem]
}

// MARK: - View Output - Actions

enum PokemonListViewAction {
    case loadPokemon
    case viewDetails(id: Int)
}
