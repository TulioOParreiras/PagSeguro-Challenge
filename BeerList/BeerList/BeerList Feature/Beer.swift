//
//  Beer.swift
//  BeerList
//
//  Created by Tulio Parreiras on 21/01/21.
//

import Foundation

public struct Beer: Equatable {
    public let id: Int
    public let name: String
    public let tagline: String
    public let description: String
    public let imageURL: URL
    public let abv: Double
    public let ibu: Double
    
    public init(id: Int,
                name: String,
                tagline: String,
                description: String,
                imageURL: URL,
                abv: Double,
                ibu: Double) {
        self.id = id
        self.name = name
        self.tagline = tagline
        self.description = description
        self.imageURL = imageURL
        self.abv = abv
        self.ibu = ibu
    }
}
