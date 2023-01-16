//
//  ArrayTableViewDataSource.swift
//  
//
//  Created by Ben on 13/01/2023.
//

import Foundation
import XCTest
import UIKit
import SharedTestHelpers
@testable import PokemonListFeature

final class ArrayTableViewDataSourceTests: XCTestCase {
    private let items = ["1", "2", "3"]

    func test_numberOfRowsInSection_givenInitWithItems_isNumberOfItemsForAnySection() {
        let sut = makeSUT(items: items)

        XCTAssertEqual(sut.tableView(UITableView(), numberOfRowsInSection: 0), items.count)
        XCTAssertEqual(sut.tableView(UITableView(), numberOfRowsInSection: 1), items.count)
        XCTAssertEqual(sut.tableView(UITableView(), numberOfRowsInSection: Int.max), items.count)
    }

    func test_updateItems_changesNumberOfRowsToMatchNewItems() {

        let sut = makeSUT(items: items)

        let newItems = ["1", "2", "3", "4"]

        XCTAssertEqual(sut.tableView(UITableView(), numberOfRowsInSection: 0), items.count)

        sut.update(newItems: newItems)

        XCTAssertEqual(sut.tableView(UITableView(), numberOfRowsInSection: 0), newItems.count)
    }

    func test_cellForRowAtIndexPath_whenRowIndexOutOfItemsRange_doesNotCallPopulateCellView() {
        let cellFactorySpy = CellFactorySpy()
        let tableViewCell = TestTableViewCell()
        cellFactorySpy.stubbedCellFactoryResult = tableViewCell

        let sut = makeSUT(items: items, cellFactory: cellFactorySpy.cellFactory)

        let tableView = UITableView()
        _ = sut.tableView(tableView, cellForRowAt: IndexPath(row: -1, section: 0))
        _ = sut.tableView(tableView, cellForRowAt: IndexPath(row: 3, section: 0))

        XCTAssertTrue(cellFactorySpy.cellFactoryParameters.isEmpty)
    }

    func test_cellForRowAtIndexPath_whenExpectedCellTypeReturnedAndIndexInRange_populatesItemAtIndexWithDequeuedCellAndReturnsIt() {
        let cellFactorySpy = CellFactorySpy()
        let tableViewCell = TestTableViewCell()
        cellFactorySpy.stubbedCellFactoryResult = tableViewCell


        let sut = makeSUT(items: items, cellFactory: cellFactorySpy.cellFactory)

        let tableView = UITableView()
        let result1 = sut.tableView(tableView, cellForRowAt: IndexPath(row: 2, section: 0))
        let result2 = sut.tableView(tableView, cellForRowAt: IndexPath(row: 1, section: 0))

        XCTAssertEqual(cellFactorySpy.cellFactoryParameters.count, 2)
        XCTAssertEqual(cellFactorySpy.cellFactoryParameters.first?.item, items[2])
        XCTAssertEqual(cellFactorySpy.cellFactoryParameters.first?.tableView, tableView)
        XCTAssertEqual(cellFactorySpy.cellFactoryParameters.last?.item, items[1])
        XCTAssertEqual(cellFactorySpy.cellFactoryParameters.last?.tableView, tableView)
        XCTAssertEqual(result1, tableViewCell)
        XCTAssertEqual(result2, tableViewCell)
    }

    private func makeSUT(items: [String] = [],
                         cellFactory: @escaping (UITableView, String) -> UITableViewCell = { _,_  in UITableViewCell() } ) -> ArrayTableViewDataSource<String> {
        let sut = ArrayTableViewDataSource(items: items, cellFactory: cellFactory)
        trackForMemoryLeaks(sut)
        return sut

    }

}

private class TestTableViewCell: UITableViewCell {}

class UITableViewSpy: UITableView {
    var dequeueReusableCellParametersList = [String]()
    var stubbedDequeueReusableCellResult: UITableViewCell?
    override func dequeueReusableCell(withIdentifier identifier: String) -> UITableViewCell? {
        dequeueReusableCellParametersList.append(identifier)
        return stubbedDequeueReusableCellResult
    }
}

class CellFactorySpy {
    var cellFactoryParameters = [(tableView: UITableView, item: String)]()
    var stubbedCellFactoryResult: UITableViewCell = UITableViewCell()
    func cellFactory(tableView: UITableView, item: String) -> UITableViewCell {
        cellFactoryParameters.append((tableView: tableView, item: item))
        return stubbedCellFactoryResult
    }
}
