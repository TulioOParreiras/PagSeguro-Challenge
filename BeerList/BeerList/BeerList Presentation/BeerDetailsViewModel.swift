//
//  BeerDetailsViewModel.swift
//  BeerList
//
//  Created by Tulio Parreiras on 26/01/21.
//

import Foundation

public struct BeerDetailsViewModel<Image> {
    public let name: String
    public let description: String
    public let ibuValue: Double?
    public let abvValue: Double
    public let tagline: String
    public let image: Image?
    public let isLoading: Bool
    public let shouldRetry: Bool
    
    public var ibu: String?  {
        guard let ibu = ibuValue else { return nil }
        return "IBU: " + String(describing: ibu)
    }
    
    public var abv: String {
        return "ABV: " + String(describing: abvValue)
    }
    
    public var hasIbu: Bool {
        return ibuValue != nil
    }
}
