//
//  LoadingTableViewCell.swift
//  
//
//  Created by Ben on 15/01/2023.
//

import UIKit

class LoadingTableViewCell: UITableViewCell {
    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    override func awakeFromNib() {
        super.awakeFromNib()
        activityIndicator.startAnimating()
    }

    override func prepareForReuse() {
        activityIndicator.startAnimating()
    }
}
