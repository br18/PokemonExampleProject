//
//  UIImageView+URL.swift
//  
//
//  Created by Ben on 16/01/2023.
//

import Foundation
import UIKit

// Do not use this in a view that is recycled as URL could be hit many times
extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
