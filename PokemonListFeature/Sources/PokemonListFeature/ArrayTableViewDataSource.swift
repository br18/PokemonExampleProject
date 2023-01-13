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

    private func makeSUT(items: [String] = [],
                         cellIdentifier: String = "",
                         populateCellView: @escaping (String, UITableViewCell) -> Void = { _,_  in } ) -> ArrayTableViewDataSource<String, UITableViewCell> {

        ArrayTableViewDataSource(items: items,
                                 cellIdentifier: cellIdentifier,
                                 populateCellView: populateCellView)

    }

}

class UITableViewSpy: UITableView {
    var dequeueReusableCellParametersList = [String]()
    override func dequeueReusableCell(withIdentifier identifier: String) -> UITableViewCell? {
        dequeueReusableCellParametersList.append(identifier)
        return super.dequeueReusableCell(withIdentifier: identifier)
    }
}
