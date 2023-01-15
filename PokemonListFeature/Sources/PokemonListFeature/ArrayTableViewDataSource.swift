//
//  ArrayTableViewDataSource.swift
//  
//
//  Created by Ben on 13/01/2023.
//

import Foundation
import UIKit

class ArrayTableViewDataSource<Item>: NSObject, UITableViewDataSource {
    private var items: [Item]
    private let cellFactory: (UITableView, Item) -> UITableViewCell

    init(items: [Item] = [],
         cellFactory: @escaping (UITableView, Item) -> UITableViewCell) {
        self.items = items
        self.cellFactory = cellFactory
    }

    func update(newItems: [Item]) {
        items = newItems
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard items.containsInRange(indexPath.row) else {
            return UITableViewCell()
        }

        return cellFactory(tableView, items[indexPath.row])
    }
}
