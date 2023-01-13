//
//  RemotePokemon.swift
//  
//
//  Created by Ben on 13/01/2023.
//

import Foundation

struct RemotePokemon: Decodable {
    let name: String
    let heightInDecimeters: Int
    let weightInHectograms: Int
    let sprites: PokemonSprites
    let types: [PokemonType]

    enum CodingKeys: String, CodingKey {
        case name
        case heightInDecimeters = "height"
        case weightInHectograms = "weight"
        case sprites
        case types
    }
}
