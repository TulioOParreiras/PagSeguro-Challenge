//
//  BeerViewModel.swift
//  BeerList
//
//  Created by Tulio Parreiras on 26/01/21.
//

import Foundation

public struct BeerViewModel<Image> {
    public let name: String
    public let abvValue: Double
    public let image: Image?
    public let isLoading: Bool
    public let shouldRetry: Bool
    
    public var abv: String {
        return "ABV: " + String(describing: abvValue)
    }
    
}
