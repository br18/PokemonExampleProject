//
//  PokemonCoordinator.swift
//  Pokemon
//
//  Created by Ben on 17/01/2023.
//

import Foundation
import UIKit
import PokemonListFeature
import PokemonDetailsFeature

@MainActor class PokemonCoordinator {
    private let navigationController: UINavigationController
    private let repository: PokemonRepository & PokemonDetailsRepository

    init(navigationController: UINavigationController,
         repository: PokemonRepository & PokemonDetailsRepository) {
        self.navigationController = navigationController
        navigationController.navigationBar.prefersLargeTitles = true
        self.repository = repository
    }

    func start() {
        let viewModel = PokemonListViewModel(pokemonRepository: repository, viewDetails: { [weak self] id in
            self?.showPokemonDetails(id: id)
        })
        navigationController.pushViewController(PokemonListViewController(viewModel: viewModel), animated: false)
    }

    private func showPokemonDetails(id: Int) {
        let viewModel = PokemonDetailsViewModel(pokemonId: id, repository: repository)
        navigationController.pushViewController(PokemonDetailsViewController(viewModel: viewModel), animated: true)
    }

}
