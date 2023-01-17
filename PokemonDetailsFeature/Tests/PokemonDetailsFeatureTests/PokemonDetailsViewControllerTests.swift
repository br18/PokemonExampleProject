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
    
    func test_onViewDidLoad_loadDataActionPerformed() {
        let viewModel = ViewModel(initialState: .loading)

        _ = makeSut(viewModel: viewModel)

        XCTAssertEqual(viewModel.performActionParameters.count, 1)
        XCTAssertEqual(viewModel.performActionParameters.first, .loadData)
    }

    func test_whenStateIsLoading_loadingViewIsShownAndErrorViewIsHidden() {

    }

    func test_whenStateIsError_loadingViewIsShownAndErrorViewIsHidden() {
        
    }

    func test_whenStateIsLoaded_loadingAndErrorViewAreHiddenAndDataIsPopulated() {

    }

    func test_whenStateIsLoadingAndTransitionsToLoaded_loadingAndErrorViewAreHiddenAndDataIsPopulated() {

    }

    func test_whenStateIsLoadingAndTransitionsToError_loadingViewIsHiddenAndErrorViewIsShown() {

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
