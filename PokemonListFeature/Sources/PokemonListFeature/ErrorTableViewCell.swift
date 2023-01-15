//
//  ErrorTableViewCell.swift
//  
//
//  Created by Ben on 15/01/2023.
//

import UIKit

class ErrorTableViewCell: UITableViewCell {
    var onRetry: (() -> Void)?

    override func prepareForReuse() {
        onRetry = nil
    }
    
    @IBAction func retryTapped(_ sender: Any) {
        onRetry?()
    }
}
