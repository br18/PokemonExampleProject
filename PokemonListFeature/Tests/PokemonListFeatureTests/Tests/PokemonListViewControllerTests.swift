//
//  PokemonListViewControllerTests.swift
//  
//
//  Created by Ben on 13/01/2023.
//

import XCTest
import Combine
import SharedTestHelpers
@testable import PokemonListFeature

@MainActor final class PokemonListViewControllerTests: XCTestCase {

    private typealias SutType = PokemonListViewController<TestViewModel>

    private typealias DataSourceType = ArrayTableViewDataSource<PokemonTableViewItem>
    private typealias TestViewModel = StubViewModel<PokemonListViewState, PokemonListViewAction>

    private let items = [PokemonListViewItem(id: 56, name: "Hello"),
                         PokemonListViewItem(id: 542, name: "World")]

    private lazy var loadedStateWithItems = PokemonListViewState(dataFetchState: .loaded, items: items)
    private let loadingStateWithoutItems = PokemonListViewState(dataFetchState: .loading, items: [])
    private lazy var loadingStateWithItems = PokemonListViewState(dataFetchState: .loading, items: items)
    private let loadedStateWithoutItems = PokemonListViewState(dataFetchState: .loaded, items: [])

    func test_title_isPokemon() {
        let viewModel = TestViewModel(initialState: loadedStateWithItems)
        let sut = makeSut(viewModel: viewModel)
        XCTAssertEqual(sut.title, "Pokemon")
    }

    func test_whenTableViewRowInPokemonRangeSelected_performsViewDetailsForPokemonItemAtRow() {
        let viewModel = TestViewModel(initialState: loadedStateWithItems)

        let sut = makeSut(viewModel: viewModel)

        sut.tableView(UITableView(), didSelectRowAt: NSIndexPath(row: 1, section: 534354) as IndexPath)
        sut.tableView(UITableView(), didSelectRowAt: NSIndexPath(row: 0, section: 1) as IndexPath)

        XCTAssertEqual(viewModel.performActionParameters.count, 3)
        XCTAssertEqual(viewModel.performActionParameters.first, .loadPokemon)
        XCTAssertEqual(viewModel.performActionParameters[1], .viewDetails(id: loadedStateWithItems.items[1].id))
        XCTAssertEqual(viewModel.performActionParameters.last, .viewDetails(id: loadedStateWithItems.items[0].id))
    }

    func test_whenTableViewRowOutOfPokemonRangeSelected_performsViewDetailsForPokemonItemAtRow() {
        let viewModel = TestViewModel(initialState: loadedStateWithItems)

        let sut = makeSut(viewModel: viewModel)

        sut.tableView(UITableView(), didSelectRowAt: NSIndexPath(row: -1, section: 0) as IndexPath)
        sut.tableView(UITableView(), didSelectRowAt: NSIndexPath(row: 2, section: 0) as IndexPath)

        XCTAssertEqual(viewModel.performActionParameters, [.loadPokemon])
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
        XCTAssertEqual(viewModel.performActionParameters.first, .loadPokemon)
    }

    func test_onViewLoaded_whenStateHasErrorAndNoItems_showsErrorAsOnlyCell() {
        let state = PokemonListViewState(dataFetchState: .error, items: [])
        let viewModel = TestViewModel(initialState: state)
        let sut = makeSut(viewModel: viewModel)

        XCTAssertEqual(sut.tableView.visibleCells.count, 1)
        XCTAssertEqual(sut.tableView.numberOfRows(inSection: 0), 1)
        XCTAssertNotNil(errorCell(sut: sut, row: 0))
    }

    func test_onViewLoaded_whenStateHasErrorAndItems_showsErrorBeneathCells() {
        let state = PokemonListViewState(dataFetchState: .error, items: items)
        let viewModel = TestViewModel(initialState: state)
        let sut = makeSut(viewModel: viewModel)

        let itemCount = items.count + 1
        XCTAssertEqual(sut.tableView.visibleCells.count, itemCount)
        XCTAssertEqual(sut.tableView.numberOfRows(inSection: 0), itemCount)
        XCTAssertEqual(getCellNameText(sut: sut, row: 0), viewModel.state.items.first?.name)
        XCTAssertEqual(getCellNameText(sut: sut, row: 1), viewModel.state.items.last?.name)
        XCTAssertNotNil(errorCell(sut: sut, row: 2))
    }

    func test_onViewLoaded_whenStateHasErrorAndRetryTapped_tellsViewModelToLoadPokemon() {
        let state = PokemonListViewState(dataFetchState: .error, items: [])
        let viewModel = TestViewModel(initialState: state)
        let sut = makeSut(viewModel: viewModel)

        guard let errorCell = errorCell(sut: sut, row: 0) else {
            XCTFail("Error cell not found")
            return
        }

        XCTAssertEqual(viewModel.performActionParameters.count, 1)

        errorCell.retryTapped(self)

        XCTAssertEqual(viewModel.performActionParameters.count, 2)
        XCTAssertEqual(viewModel.performActionParameters.last, .loadPokemon)
    }


    func test_whenWillDisplayNotLastCell_andStateLoaded_doesNotRequestLoadPokemon() {
        let itemCount = 100
        let manyItems = Array(repeating: items[0], count: itemCount)
        let state = PokemonListViewState(dataFetchState: .loaded, items: manyItems)
        let viewModel = TestViewModel(initialState: state)
        let sut = makeSut(viewModel: viewModel)

        XCTAssertEqual(viewModel.performActionParameters.count, 1)

        sut.tableView(sut.tableView, willDisplay: UITableViewCell(), forRowAt: IndexPath(row: itemCount - 2, section: 0))

        XCTAssertEqual(viewModel.performActionParameters.count, 1)
    }

    func test_whenWillDisplayLastCell_andStateError_doesNotRequestLoadPokemon() {
        let itemCount = 100
        let manyItems = Array(repeating: items[0], count: itemCount)
        let state = PokemonListViewState(dataFetchState: .error, items: manyItems)
        let viewModel = TestViewModel(initialState: state)
        let sut = makeSut(viewModel: viewModel)

        XCTAssertEqual(viewModel.performActionParameters.count, 1)

        sut.tableView(sut.tableView, willDisplay: UITableViewCell(), forRowAt: IndexPath(row: itemCount - 2, section: 0))

        XCTAssertEqual(viewModel.performActionParameters.count, 1)
    }

    func test_whenWillDisplayLastCell_andStateLoading_doesNotRequestLoadPokemon() {
        let itemCount = 100
        let manyItems = Array(repeating: items[0], count: itemCount)
        let state = PokemonListViewState(dataFetchState: .loading, items: manyItems)
        let viewModel = TestViewModel(initialState: state)
        let sut = makeSut(viewModel: viewModel)

        XCTAssertEqual(viewModel.performActionParameters.count, 1)

        sut.tableView(sut.tableView, willDisplay: UITableViewCell(), forRowAt: IndexPath(row: itemCount - 2, section: 0))

        XCTAssertEqual(viewModel.performActionParameters.count, 1)
    }

    func test_whenWillDisplayLastCell_andStateLoaded_requestsLoadPokemon() {
        let itemCount = 100
        let manyItems = Array(repeating: items[0], count: itemCount)
        let state = PokemonListViewState(dataFetchState: .loaded, items: manyItems)
        let viewModel = TestViewModel(initialState: state)
        let sut = makeSut(viewModel: viewModel)

        XCTAssertEqual(viewModel.performActionParameters.count, 1)

        sut.tableView(sut.tableView, willDisplay: UITableViewCell(), forRowAt: IndexPath(row: itemCount - 1, section: 0))

        XCTAssertEqual(viewModel.performActionParameters.count, 2)
        XCTAssertEqual(viewModel.performActionParameters.last, .loadPokemon)
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

    private func errorCell(sut: SutType, row: Int) -> ErrorTableViewCell? {
        return sut.tableView.cellForRow(at: IndexPath(row: row, section: 0)) as? ErrorTableViewCell
    }
    
    private func makeSut(viewModel: TestViewModel) -> SutType {
        let sut = PokemonListViewController(viewModel: viewModel)
        trackForMemoryLeaks(sut)
        let _ = sut.view
        return sut
    }
}

extension PokemonListViewAction: Equatable {
    public static func == (lhs: PokemonListViewAction, rhs: PokemonListViewAction) -> Bool {
        switch (lhs, rhs) {
        case (.loadPokemon, .loadPokemon):
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
