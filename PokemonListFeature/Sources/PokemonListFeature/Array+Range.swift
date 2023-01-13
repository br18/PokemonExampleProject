//
//  Array+Range.swift
//  
//
//  Created by Ben on 13/01/2023.
//

import Foundation

extension Array {
    func containsInRange(_ index: Int) -> Bool {
        range().contains(index)
    }

    private func range() -> Range<Int> {
        return 0..<count
    }
}
