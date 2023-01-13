//
//  ArrayTableViewDataSource.swift
//  
//
//  Created by Ben on 13/01/2023.
//

import Foundation
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
        guard items.containsInRange(indexPath.row) else {
            return UITableViewCell()
        }

        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? CellView else {
            return UITableViewCell()
        }

        populateCellView(items[indexPath.row], cell)

        return cell
    }
}
