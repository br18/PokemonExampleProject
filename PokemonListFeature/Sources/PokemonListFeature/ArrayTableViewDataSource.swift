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
        //items = newItems
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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

    private func makeSUT(items: [String] = [],
                         cellIdentifier: String = "",
                         populateCellView: @escaping (String, UITableViewCell) -> Void = { _,_  in } ) -> ArrayTableViewDataSource<String, UITableViewCell> {

        ArrayTableViewDataSource(items: items,
                                 cellIdentifier: cellIdentifier,
                                 populateCellView: populateCellView)

    }

}

