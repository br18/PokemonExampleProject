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

    private typealias SutType = PokemonListViewController<TestViewModel>

    private typealias DataSourceType = ArrayTableViewDataSource<PokemonTableViewItem>
    private typealias TestViewModel = StubViewModel<PokemonListViewState, PokemonListViewAction>

    private let items = [PokemonListViewItem(id: 56, name: "Hello"),
                         PokemonListViewItem(id: 542, name: "World")]

    private lazy var loadedStateWithItems = PokemonListViewState(dataFetchState: .loaded, items: items)
    private let loadingStateWithoutItems = PokemonListViewState(dataFetchState: .loading, items: [])
    private lazy var loadingStateWithItems = PokemonListViewState(dataFetchState: .loading, items: items)
    private let loadedStateWithoutItems = PokemonListViewState(dataFetchState: .loaded, items: [])
    

    func test_whenTableViewRowInPokemonRangeSelected_performsViewDetailsForPokemonItemAtRow() {
        let viewModel = TestViewModel(initialState: loadedStateWithItems)

        let sut = makeSut(viewModel: viewModel)

        sut.tableView(UITableView(), didSelectRowAt: NSIndexPath(row: 1, section: 534354) as IndexPath)
        sut.tableView(UITableView(), didSelectRowAt: NSIndexPath(row: 0, section: 1) as IndexPath)

        XCTAssertEqual(viewModel.performActionParameters.count, 3)
        XCTAssertEqual(viewModel.performActionParameters.first, .loadData)
        XCTAssertEqual(viewModel.performActionParameters[1], .viewDetails(id: loadedStateWithItems.items[1].id))
        XCTAssertEqual(viewModel.performActionParameters.last, .viewDetails(id: loadedStateWithItems.items[0].id))
    }

    func test_whenTableViewRowOutOfPokemonRangeSelected_performsViewDetailsForPokemonItemAtRow() {
        let viewModel = TestViewModel(initialState: loadedStateWithItems)

        let sut = makeSut(viewModel: viewModel)

        sut.tableView(UITableView(), didSelectRowAt: NSIndexPath(row: -1, section: 0) as IndexPath)
        sut.tableView(UITableView(), didSelectRowAt: NSIndexPath(row: 2, section: 0) as IndexPath)

        XCTAssertEqual(viewModel.performActionParameters, [.loadData])
    }

    func test_whenStateIsLoading_loadingViewIsShown() {
        let viewModel = TestViewModel(initialState: loadingStateWithoutItems)

        let sut = makeSut(viewModel: viewModel)

        XCTAssertEqual(sut.tableView.rowCount(), 1)
        XCTAssertTrue(hasLoadingCell(sut: sut, row: 0))
    }

    func test_whenStateIsNotLoading_loadingViewIsHidden() {
        let viewModel = TestViewModel(initialState: loadedStateWithoutItems)

        let sut = makeSut(viewModel: viewModel)

        XCTAssertEqual(sut.tableView.rowCount(), 0)
    }

    func test_whenInitialStateIsNotLoadingAndStateChangesToLoading_loadingViewIsShown() {
        let viewModel = TestViewModel(initialState: loadedStateWithoutItems)

        let sut = makeSut(viewModel: viewModel)

        viewModel.state = loadingStateWithoutItems

        XCTAssertEqual(sut.tableView.rowCount(), 1)
        XCTAssertTrue(hasLoadingCell(sut: sut, row: 0))
    }

    func test_whenInitialStateIsLoadingAndStateChangesToNotLoading_loadingViewIsHidden() {
        let viewModel = TestViewModel(initialState: loadingStateWithoutItems)

        let sut = makeSut(viewModel: viewModel)

        viewModel.state = loadedStateWithoutItems

        XCTAssertEqual(sut.tableView.rowCount(), 0)
    }

    func test_whenStateIsLoadingWithItems_showsItemsWithLoadingCellAtTheBottom() {
        let viewModel = TestViewModel(initialState: loadingStateWithItems)

        let sut = makeSut(viewModel: viewModel)

        let expectedRowCount = items.count + 1
        XCTAssertEqual(sut.tableView.rowCount(), expectedRowCount)
        XCTAssertEqual(sut.tableView.visibleCells.count, expectedRowCount)
        XCTAssertEqual(getCellNameText(sut: sut, row: 0), viewModel.state.items.first?.name)
        XCTAssertEqual(getCellNameText(sut: sut, row: 1), viewModel.state.items.last?.name)
        XCTAssertTrue(hasLoadingCell(sut: sut, row: 2))
    }


    func test_onViewLoaded_tableViewDelegateIsSut() {
        let viewModel = TestViewModel(initialState: loadingStateWithoutItems)
        let sut = makeSut(viewModel: viewModel)

        XCTAssertTrue(sut.tableView.delegate === sut)
    }

    func test_onViewLoaded_tableViewDataSourceIsArrayTableViewDataSourceWithPokemonCell() {
        let viewModel = TestViewModel(initialState: loadingStateWithoutItems)
        let sut = makeSut(viewModel: viewModel)

        XCTAssertTrue(sut.tableView.dataSource is DataSourceType)
    }

    func test_onViewLoaded_givenInitialStateHasItems_createsItemsAsRowsInTableView() {
        let viewModel = TestViewModel(initialState: loadedStateWithItems)
        let sut = makeSut(viewModel: viewModel)

        XCTAssertEqual(sut.tableView.visibleCells.count, 2)
        XCTAssertEqual(sut.tableView.numberOfRows(inSection: 0), 2)
        XCTAssertEqual(getCellNameText(sut: sut, row: 0), viewModel.state.items.first?.name)
        XCTAssertEqual(getCellNameText(sut: sut, row: 1), viewModel.state.items.last?.name)
    }

    func test_whenStateItemsChange_updatesItemsInDataSource() {
        let viewModel = TestViewModel(initialState: loadedStateWithItems)
        let sut = makeSut(viewModel: viewModel)

        viewModel.state = PokemonListViewState(dataFetchState: .loaded, items: [PokemonListViewItem(id: 56, name: "Hello")])

        XCTAssertEqual(sut.tableView.visibleCells.count, 1)
        XCTAssertEqual(sut.tableView.numberOfRows(inSection: 0), 1)
        XCTAssertEqual(getCellNameText(sut: sut, row: 0), viewModel.state.items.first?.name)
    }

    func test_onViewLoaded_requestsLoadData() {
        let viewModel = TestViewModel(initialState: loadedStateWithItems)
        let _ = makeSut(viewModel: viewModel)

        XCTAssertEqual(viewModel.performActionParameters.count, 1)
        XCTAssertEqual(viewModel.performActionParameters.first, .loadData)
    }

    private func hasLoadingCell(sut: SutType, row: Int) -> Bool {
        return sut.tableView.cellForRow(at: IndexPath(row: row, section: 0)) is LoadingTableViewCell
    }

    private func getCellNameText(sut: SutType, row: Int) -> String? {
        guard let cell = sut.tableView.cellForRow(at: IndexPath(row: row, section: 0)) as? PokemonListTableViewCell else {
            return nil
        }
        return cell.nameLabel.text
    }
    
    private func makeSut(viewModel: TestViewModel) -> SutType {
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

private extension UITableView {
    func rowCount() -> Int {
        numberOfRows(inSection: 0)
    }
}
