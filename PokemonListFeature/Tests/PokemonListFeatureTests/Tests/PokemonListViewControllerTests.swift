//
//  PokemonListViewControllerTests.swift
//  
//
//  Created by Ben on 13/01/2023.
//

import XCTest
import Combine
@testable import PokemonListFeature

final class PokemonListViewControllerTests: XCTestCase {
    private typealias TestViewModel = StubViewModel<PokemonListViewState, PokemonListViewAction>

    private let loadedState = PokemonListViewState(isLoading: false, items: [PokemonListViewItem(id: 56, name: "Hello"),
                                                                             PokemonListViewItem(id: 542, name: "World")])

    private let loadingState = PokemonListViewState(isLoading: true, items: [])

    func test_whenTableViewRowInPokemonRangeSelected_performsViewDetailsForPokemonItemAtRow() {
        let viewModel = TestViewModel(initialState: loadedState)

        let sut = makeSut(viewModel: viewModel)

        sut.tableView(UITableView(), didSelectRowAt: NSIndexPath(row: 1, section: 534354) as IndexPath)
        sut.tableView(UITableView(), didSelectRowAt: NSIndexPath(row: 0, section: 1) as IndexPath)

        XCTAssertEqual(viewModel.performActionParameters.count, 2)
        XCTAssertEqual(viewModel.performActionParameters.first, .viewDetails(id: loadedState.items[1].id))
        XCTAssertEqual(viewModel.performActionParameters.last, .viewDetails(id: loadedState.items[0].id))
    }

    func test_whenTableViewRowOutOfPokemonRangeSelected_performsViewDetailsForPokemonItemAtRow() {
        let viewModel = TestViewModel(initialState: loadedState)

        let sut = makeSut(viewModel: viewModel)

        sut.tableView(UITableView(), didSelectRowAt: NSIndexPath(row: -1, section: 0) as IndexPath)
        sut.tableView(UITableView(), didSelectRowAt: NSIndexPath(row: 2, section: 0) as IndexPath)

        XCTAssertEqual(viewModel.performActionParameters.count, 0)
    }

    func test_whenStateIsLoading_loadingViewIsShown() {
        let viewModel = TestViewModel(initialState: loadingState)

        let sut = makeSut(viewModel: viewModel)

        XCTAssertEqual(sut.loadingView.isHidden, false)
    }

    func test_whenStateIsNotLoading_loadingViewIsHidden() {
        let viewModel = TestViewModel(initialState: loadedState)

        let sut = makeSut(viewModel: viewModel)

        XCTAssertEqual(sut.loadingView.isHidden, true)
    }

    func test_whenInitialStateIsNotLoadingAndStateChangesToLoading_loadingViewIsShown() {
        let viewModel = TestViewModel(initialState: loadedState)

        let sut = makeSut(viewModel: viewModel)

        viewModel.state = loadingState

        XCTAssertEqual(sut.loadingView.isHidden, false)
    }

    func test_whenInitialStateIsLoadingAndStateChangesToNotLoading_loadingViewIsHidden() {
        let viewModel = TestViewModel(initialState: loadingState)

        let sut = makeSut(viewModel: viewModel)

        viewModel.state = loadedState

        XCTAssertEqual(sut.loadingView.isHidden, true)
    }

    private func makeSut(viewModel: TestViewModel) -> PokemonListViewController<TestViewModel> {
        let sut = PokemonListViewController(viewModel: viewModel)
        //sut.loadViewIfNeeded()

        let _ = sut.view
        return sut
    }

}

extension PokemonListViewAction: Equatable {
    public static func == (lhs: PokemonListViewAction, rhs: PokemonListViewAction) -> Bool {
        switch (lhs, rhs) {
        case (.loadData, .loadData):
            return true
        case (.loadMoreItems, .loadMoreItems):
            return true
        case (.viewDetails(let lhsId), .viewDetails(let rhsId)):
            return lhsId == rhsId
        default:
            return false
        }
    }
}

//extension XCTestCase {
//    func waitForViewModelToChange(object: any ViewModel) {
//        var cancellable: Cancellable?
//        object.objectWillChange.sink(receiveCompletion: <#T##((Subscribers.Completion<Publisher.Failure>) -> Void)##((Subscribers.Completion<Publisher.Failure>) -> Void)##(Subscribers.Completion<Publisher.Failure>) -> Void#>, receiveValue: <#T##((Publisher.Output) -> Void)##((Publisher.Output) -> Void)##(Publisher.Output) -> Void#>)
//
//    }
//}
