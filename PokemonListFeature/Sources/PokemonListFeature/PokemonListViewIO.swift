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

struct PokemonListViewState {
    var isLoading: Bool
    var items: [PokemonListViewItem]
    var errorMessage: String?
}

// MARK: - View Output - Actions

enum PokemonListViewAction {
    case loadData
    case loadMoreItems
    case viewDetails(id: Int)
}
