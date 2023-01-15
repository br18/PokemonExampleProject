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
    private typealias DataSourceType = ArrayTableViewDataSource<PokemonListViewItem>
    private typealias TestViewModel = StubViewModel<PokemonListViewState, PokemonListViewAction>

    private let loadedState = PokemonListViewState(isLoading: false, items: [PokemonListViewItem(id: 56, name: "Hello"),
                                                                             PokemonListViewItem(id: 542, name: "World")])

    private let loadingState = PokemonListViewState(isLoading: true, items: [])

    func test_whenTableViewRowInPokemonRangeSelected_performsViewDetailsForPokemonItemAtRow() {
        let viewModel = TestViewModel(initialState: loadedState)

        let sut = makeSut(viewModel: viewModel)

        sut.tableView(UITableView(), didSelectRowAt: NSIndexPath(row: 1, section: 534354) as IndexPath)
        sut.tableView(UITableView(), didSelectRowAt: NSIndexPath(row: 0, section: 1) as IndexPath)

        XCTAssertEqual(viewModel.performActionParameters.count, 3)
        XCTAssertEqual(viewModel.performActionParameters.first, .loadData)
        XCTAssertEqual(viewModel.performActionParameters[1], .viewDetails(id: loadedState.items[1].id))
        XCTAssertEqual(viewModel.performActionParameters.last, .viewDetails(id: loadedState.items[0].id))
    }

    func test_whenTableViewRowOutOfPokemonRangeSelected_performsViewDetailsForPokemonItemAtRow() {
        let viewModel = TestViewModel(initialState: loadedState)

        let sut = makeSut(viewModel: viewModel)

        sut.tableView(UITableView(), didSelectRowAt: NSIndexPath(row: -1, section: 0) as IndexPath)
        sut.tableView(UITableView(), didSelectRowAt: NSIndexPath(row: 2, section: 0) as IndexPath)

        XCTAssertEqual(viewModel.performActionParameters, [.loadData])
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

    func test_onViewLoaded_tableViewDelegateIsSut() {
        let viewModel = TestViewModel(initialState: loadingState)
        let sut = makeSut(viewModel: viewModel)

        XCTAssertTrue(sut.tableView.delegate === sut)
    }

    func test_onViewLoaded_tableViewDataSourceIsArrayTableViewDataSourceWithPokemonCell() {
        let viewModel = TestViewModel(initialState: loadingState)
        let sut = makeSut(viewModel: viewModel)

        XCTAssertTrue(sut.tableView.dataSource is DataSourceType)
    }

    func test_onViewLoaded_givenInitialStateHasItems_createsItemsAsRowsInTableView() {
        let viewModel = TestViewModel(initialState: loadedState)
        let sut = makeSut(viewModel: viewModel)

        XCTAssertEqual(sut.tableView.visibleCells.count, 2)
        XCTAssertEqual(sut.tableView.numberOfRows(inSection: 0), 2)
        XCTAssertEqual(getCellNameText(sut: sut, row: 0), viewModel.state.items.first?.name)
        XCTAssertEqual(getCellNameText(sut: sut, row: 1), viewModel.state.items.last?.name)
    }

    func test_whenStateItemsChange_updatesItemsInDataSource() {
        let viewModel = TestViewModel(initialState: loadedState)
        let sut = makeSut(viewModel: viewModel)

        viewModel.state = PokemonListViewState(isLoading: false, items: [PokemonListViewItem(id: 56, name: "Hello")])


        XCTAssertEqual(sut.tableView.visibleCells.count, 1)
        XCTAssertEqual(sut.tableView.numberOfRows(inSection: 0), 1)
        XCTAssertEqual(getCellNameText(sut: sut, row: 0), viewModel.state.items.first?.name)
    }

    func test_onViewLoaded_requestsLoadData() {
        let viewModel = TestViewModel(initialState: loadedState)
        let _ = makeSut(viewModel: viewModel)

        XCTAssertEqual(viewModel.performActionParameters.count, 1)
        XCTAssertEqual(viewModel.performActionParameters.first, .loadData)
    }

    private func getCellNameText(sut: PokemonListViewController<TestViewModel>, row: Int) -> String? {
        guard let cell = sut.tableView.cellForRow(at: IndexPath(row: row, section: 0)) as? PokemonListTableViewCell else {
            return nil
        }
        return cell.nameLabel.text
    }
    
    private func makeSut(viewModel: TestViewModel) -> PokemonListViewController<TestViewModel> {
        let sut = PokemonListViewController(viewModel: viewModel)
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
