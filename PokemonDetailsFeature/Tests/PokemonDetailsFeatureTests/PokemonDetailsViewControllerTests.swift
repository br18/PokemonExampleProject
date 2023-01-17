//
//  PokemonDetailsViewControllerTests.swift
//  
//
//  Created by Ben on 16/01/2023.
//

import XCTest
import SharedUITests
import SharedTestHelpers
@testable import PokemonDetailsFeature

@MainActor final class PokemonDetailsViewControllerTests: XCTestCase {
    typealias ViewModel = StubViewModel<PokemonDetailsViewState, PokemonDetailsViewAction>

    let pokemonImageURL = URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png")!
    lazy var details = PokemonLoadedDetailsViewState(name: "Name",
                                                imageURL: pokemonImageURL,
                                                weight: "35kg",
                                                height: "4.5m",
                                                types: "Grass, Water")
    
    func test_onViewDidLoad_loadDataActionPerformed() {
        let viewModel = ViewModel(initialState: .loading)

        _ = makeSut(viewModel: viewModel)

        XCTAssertEqual(viewModel.performActionParameters.count, 1)
        XCTAssertEqual(viewModel.performActionParameters.first, .loadData)
    }

    func test_whenStateIsLoading_loadingViewIsShownAndErrorViewIsHidden() {
        let viewModel = ViewModel(initialState: .loading)

        let sut = makeSut(viewModel: viewModel)

        XCTAssertEqual(sut.loadingView.isHidden, false)
        XCTAssertEqual(sut.detailsContainerView.isHidden, true)
        XCTAssertEqual(sut.errorView.isHidden, true)
    }

    func test_whenStateIsError_errorViewIsShownAndLoadedViewIsHidden() {
        let viewModel = ViewModel(initialState: .error)

        let sut = makeSut(viewModel: viewModel)

        XCTAssertEqual(sut.loadingView.isHidden, true)
        XCTAssertEqual(sut.detailsContainerView.isHidden, true)
        XCTAssertEqual(sut.errorView.isHidden, false)
    }

    func test_whenStateIsLoaded_loadingAndErrorViewAreHiddenAndDataIsPopulated() {
        let viewModel = ViewModel(initialState: .loaded(details: details))

        let sut = makeSut(viewModel: viewModel)

        XCTAssertEqual(sut.loadingView.isHidden, true)
        XCTAssertEqual(sut.detailsContainerView.isHidden, false)
        XCTAssertEqual(sut.errorView.isHidden, true)
        XCTAssertEqual(sut.title, details.name)
        XCTAssertEqual(sut.weightLabel.text, details.weight)
        XCTAssertEqual(sut.heightLabel.text, details.height)
        XCTAssertEqual(sut.typesLabel.text, details.types)
    }

    func test_whenStateIsLoadingAndTransitionsToLoaded_loadingAndErrorViewAreHiddenAndDataIsPopulated() {
        let viewModel = ViewModel(initialState: .loading)

        let sut = makeSut(viewModel: viewModel)

        viewModel.state = .loaded(details: details)

        XCTAssertEqual(sut.loadingView.isHidden, true)
        XCTAssertEqual(sut.detailsContainerView.isHidden, false)
        XCTAssertEqual(sut.errorView.isHidden, true)
        XCTAssertEqual(sut.title, details.name)
        XCTAssertEqual(sut.weightLabel.text, details.weight)
        XCTAssertEqual(sut.heightLabel.text, details.height)
        XCTAssertEqual(sut.typesLabel.text, details.types)
    }

    func test_whenStateIsLoadingAndTransitionsToError_loadingViewIsHiddenAndErrorViewIsShown() {
        let viewModel = ViewModel(initialState: .loading)

        let sut = makeSut(viewModel: viewModel)

        viewModel.state = .error

        XCTAssertEqual(sut.loadingView.isHidden, true)
        XCTAssertEqual(sut.detailsContainerView.isHidden, true)
        XCTAssertEqual(sut.errorView.isHidden, false)
    }

    func test_whenErrorRetryButtonTapped_loadActionDataIsPerformed() {
        let viewModel = ViewModel(initialState: .loading)

        let sut = makeSut(viewModel: viewModel)

        XCTAssertEqual(viewModel.performActionParameters.count, 1)

        sut.retryButtonTapped(self)

        XCTAssertEqual(viewModel.performActionParameters.count, 2)
        XCTAssertEqual(viewModel.performActionParameters.first, .loadData)
        XCTAssertEqual(viewModel.performActionParameters.last, .loadData)
    }

    private func makeSut(viewModel: ViewModel) -> PokemonDetailsViewController<ViewModel> {
        let viewController = PokemonDetailsViewController(viewModel: viewModel)
        _ = viewController.view
        trackForMemoryLeaks(viewController)
        return viewController
    }

}
