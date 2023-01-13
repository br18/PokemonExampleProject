//
//  PokemonListViewControllerTests.swift
//  
//
//  Created by Ben on 13/01/2023.
//

import XCTest
@testable import PokemonListFeature



final class PokemonListViewControllerTests: XCTestCase {
    private typealias TestViewModel = StubViewModel<PokemonListViewState, PokemonListViewAction>

    private let loadedState = PokemonListViewState(isLoading: false, items: [PokemonListViewItem(id: 56, name: "Hello"),
                                                                             PokemonListViewItem(id: 542, name: "World")])

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

    private func makeSut(viewModel: TestViewModel) -> PokemonListViewController<TestViewModel> {
        let sut = PokemonListViewController(viewModel: viewModel)
        sut.loadViewIfNeeded()
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
