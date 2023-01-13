//
//  PokemonSprites.swift
//  
//
//  Created by Ben on 13/01/2023.
//

import Foundation

struct PokemonSprites: Decodable {
    enum CodingKeys: String, CodingKey {
      case frontDefault = "front_default"
    }

    let frontDefault: URL
}
