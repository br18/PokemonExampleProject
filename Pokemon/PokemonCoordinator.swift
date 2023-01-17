//
//  PokemonCoordinator.swift
//  Pokemon
//
//  Created by Ben on 17/01/2023.
//

import Foundation
import UIKit

class PokemonCoordinator {
    private let navigationController: UINavigationController
    private let dependencies: Dependencies

    struct Dependencies {
        var makeListView: (@escaping (Int) -> Void) -> UIViewController
        var makeDetailsView: (Int) -> UIViewController
    }

    init(navigationController: UINavigationController, dependencies: Dependencies) {
        self.navigationController = navigationController
        navigationController.navigationBar.prefersLargeTitles = true
        self.dependencies = dependencies
    }

    func start() {
        navigationController.pushViewController(dependencies.makeListView { [weak self] id in
            self?.showPokemonDetails(id: id)
        }, animated: false)
    }

    private func showPokemonDetails(id: Int) {
        navigationController.pushViewController(dependencies.makeDetailsView(id), animated: true)
    }
}
