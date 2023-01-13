//
//  NamedAPIResourceList.swift
//  
//
//  Created by Ben on 13/01/2023.
//

import Foundation

struct NamedAPIResourceList: Decodable {
    let count: Int
    let results: [NamedAPIResource]
}
