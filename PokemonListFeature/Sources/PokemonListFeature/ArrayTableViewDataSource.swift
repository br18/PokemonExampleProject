//
//  ArrayTableViewDataSource.swift
//  
//
//  Created by Ben on 13/01/2023.
//

import Foundation
import XCTest
import UIKit

class ArrayTableViewDataSource<Item, CellView: UITableViewCell>: NSObject, UITableViewDataSource {
    private var items: [Item]
    private let cellIdentifier: String
    private let populateCellView: (Item, CellView) -> Void

    init(items: [Item] = [],
         cellIdentifier: String,
         populateCellView: @escaping (Item, CellView) -> Void) {
        self.items = items
        self.cellIdentifier = cellIdentifier
        self.populateCellView = populateCellView
    }

    func update(newItems: [Item]) {
        items = newItems
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        _ = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        return UITableViewCell()
    }
}


final class ArrayTableViewDataSourceTests: XCTestCase {

    func test_numberOfRowsInSection_givenInitWithItems_isNumberOfItemsForAnySection() {
        let items = ["1", "2", "3"]

        let sut = makeSUT(items: items)

        XCTAssertEqual(sut.tableView(UITableView(), numberOfRowsInSection: 0), items.count)
        XCTAssertEqual(sut.tableView(UITableView(), numberOfRowsInSection: 1), items.count)
        XCTAssertEqual(sut.tableView(UITableView(), numberOfRowsInSection: Int.max), items.count)
    }

    func test_updateItems_changesNumberOfRowsToMatchNewItems() {
        let items = ["1", "2", "3"]

        let sut = makeSUT(items: items)

        let newItems = ["1", "2", "3", "4"]

        XCTAssertEqual(sut.tableView(UITableView(), numberOfRowsInSection: 0), items.count)

        sut.update(newItems: newItems)

        XCTAssertEqual(sut.tableView(UITableView(), numberOfRowsInSection: 0), newItems.count)
    }

    func test_cellForRowAtIndexPath_givenInitWithCellIdentifier_dequeuesCellWithIdentifier() {
        let cellIdentifier = "fwjbfwej"
        let sut = makeSUT(cellIdentifier: cellIdentifier)

        let tableViewSpy = UITableViewSpy()

        _ = sut.tableView(tableViewSpy, cellForRowAt: IndexPath(item: 0, section: 0))
        _ = sut.tableView(tableViewSpy, cellForRowAt: IndexPath(item: 1, section: 0))

        XCTAssertEqual(tableViewSpy.dequeueReusableCellParametersList.count, 2)
        XCTAssertEqual(tableViewSpy.dequeueReusableCellParametersList.first, cellIdentifier)
        XCTAssertEqual(tableViewSpy.dequeueReusableCellParametersList.last, cellIdentifier)
    }

    func test_cellForRowAtIndexPath_whenCellTypeReturnedIsNotTypeForPopulateCellView_doesNotCallPopulateCellView() {
        let items = ["1", "2", "3"]

        var capturedPopulateCellViewCalls = [(item: String, view: TestTableViewCell)]()
        let populateCellView: (String, TestTableViewCell) -> Void = { item, view in
            capturedPopulateCellViewCalls.append((item: item, view: view))
        }

        let tableView = UITableViewSpy()
        tableView.stubbedDequeueReusableCellResult = UITableViewCell()

        let sut = makeSUT(items: items, populateCellView: populateCellView)

        _ = sut.tableView(tableView, cellForRowAt: IndexPath(row: 1, section: 0))

        XCTAssertTrue(capturedPopulateCellViewCalls.isEmpty)
    }

    func test_cellForRowAtIndexPath_whenExpectedCellTypeReturnedButRowIndexOutOfItemsRange_doesNotCallPopulateCellView() {
        let items = ["1", "2", "3"]

        var capturedPopulateCellViewCalls = [(item: String, view: TestTableViewCell)]()
        let populateCellView: (String, TestTableViewCell) -> Void = { item, view in
            capturedPopulateCellViewCalls.append((item: item, view: view))
        }

        let tableView = UITableViewSpy()
        tableView.stubbedDequeueReusableCellResult = TestTableViewCell()

        let sut = makeSUT(items: items, populateCellView: populateCellView)

        _ = sut.tableView(tableView, cellForRowAt: IndexPath(row: -1, section: 0))
        _ = sut.tableView(tableView, cellForRowAt: IndexPath(row: 3, section: 0))

        XCTAssertTrue(capturedPopulateCellViewCalls.isEmpty)
    }

    private func makeSUT(items: [String] = [],
                         cellIdentifier: String = "",
                         populateCellView: @escaping (String, TestTableViewCell) -> Void = { _,_  in } ) -> ArrayTableViewDataSource<String, TestTableViewCell> {
        ArrayTableViewDataSource(items: items,
                                 cellIdentifier: cellIdentifier,
                                 populateCellView: populateCellView)

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
