//
//  PokemonCoordinatorTests.swift
//  PokemonTests
//
//  Created by Ben on 17/01/2023.
//

import XCTest
import SharedTestHelpers
@testable import Pokemon

@MainActor final class PokemonCoordinatorTests: XCTestCase {


    func test_start_pushesListViewToNavigation() {
        let navigationController = NavigationControllerSpy()
        let dependenciesSpy = DependenciesSpy()

        let sut = makeSut(navigationController: navigationController,
                          dependencies: dependenciesSpy.getDependencies())

        sut.start()

        XCTAssertEqual(navigationController.viewControllers.count, 1)
        XCTAssertEqual(navigationController.viewControllers.first, dependenciesSpy.stubbedMakeListView)
        XCTAssertEqual(navigationController.pushViewControllerParametersList.count, 1)
        XCTAssertFalse(navigationController.pushViewControllerParametersList.first?.animated ?? true)
        XCTAssertEqual(navigationController.pushViewControllerParametersList.first?.viewController, dependenciesSpy.stubbedMakeListView)
    }

    func test_viewDetailsAfterStart_pushesDetailsViewToNavigation() {
        let pokemonId = 35
        let navigationController = NavigationControllerSpy()
        let dependenciesSpy = DependenciesSpy()

        let sut = makeSut(navigationController: navigationController,
                          dependencies: dependenciesSpy.getDependencies())

        sut.start()

        XCTAssertEqual(dependenciesSpy.makeListViewParametersList.count, 1)
        dependenciesSpy.makeListViewParametersList.first?(pokemonId)

        XCTAssertEqual(navigationController.viewControllers.count, 2)
        XCTAssertEqual(navigationController.viewControllers.first, dependenciesSpy.stubbedMakeListView)
        XCTAssertEqual(navigationController.viewControllers.last, dependenciesSpy.stubbedMakeDetailsView)
        XCTAssertEqual(navigationController.pushViewControllerParametersList.count, 2)
        XCTAssertFalse(navigationController.pushViewControllerParametersList.first?.animated ?? true)
        XCTAssertEqual(navigationController.pushViewControllerParametersList.first?.viewController, dependenciesSpy.stubbedMakeListView)
        XCTAssertTrue(navigationController.pushViewControllerParametersList.last?.animated ?? false)
        XCTAssertEqual(navigationController.pushViewControllerParametersList.last?.viewController, dependenciesSpy.stubbedMakeDetailsView)

        XCTAssertEqual(dependenciesSpy.makeDetailsViewParameterList.count, 1)
        XCTAssertEqual(dependenciesSpy.makeDetailsViewParameterList.first, pokemonId)
    }

    private func makeSut(navigationController: UINavigationController, dependencies: PokemonCoordinator.Dependencies) -> PokemonCoordinator {
        let sut = PokemonCoordinator(navigationController: navigationController, dependencies: dependencies)
        trackForMemoryLeaks(sut)
        return sut
    }
}

private class NavigationControllerSpy: UINavigationController {
    var pushViewControllerParametersList = [(viewController: UIViewController, animated: Bool)]()
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        pushViewControllerParametersList.append((viewController, animated))
        super.pushViewController(viewController, animated: false)
    }
}

private class DependenciesSpy {

    var makeDetailsViewParameterList = [Int]()
    var makeListViewParametersList = [(Int) -> Void]()
    var stubbedMakeDetailsView = UIViewController()
    var stubbedMakeListView = UIViewController()

    func getDependencies() -> PokemonCoordinator.Dependencies {
        return PokemonCoordinator.Dependencies { viewDetails in
            self.makeListViewParametersList.append(viewDetails)
            return self.stubbedMakeListView
        } makeDetailsView: { id in
            self.makeDetailsViewParameterList.append(id)
            return self.stubbedMakeDetailsView
        }
    }

}
