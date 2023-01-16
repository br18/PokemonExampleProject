//
//  PokemonDetails.swift
//  
//
//  Created by Ben on 15/01/2023.
//

import Foundation

public struct PokemonDetails {
    public let name: String
    public let image: URL
    public let heightInDecimeters: Int
    public let weightInHectograms: Int
    public let types: [String]

    public init(name: String,
                image: URL,
                heightInDecimeters: Int,
                weightInHectograms: Int,
                types: [String]) {
        self.name = name
        self.image = image
        self.heightInDecimeters = heightInDecimeters
        self.weightInHectograms = weightInHectograms
        self.types = types
    }

}
