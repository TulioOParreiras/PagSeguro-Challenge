//
//  BeerViewModel.swift
//  BeerList
//
//  Created by Tulio Parreiras on 26/01/21.
//

import Foundation

public struct BeerViewModel<Image> {
    public let name: String
    public let ibuValue: Double?
    public let image: Image?
    public let isLoading: Bool
    public let shouldRetry: Bool
    
    public var ibu: String?  {
        guard let ibu = ibuValue else { return nil }
        return String(describing: ibu)
    }
    
    public var hasIbu: Bool {
        return ibuValue != nil
    }
}
