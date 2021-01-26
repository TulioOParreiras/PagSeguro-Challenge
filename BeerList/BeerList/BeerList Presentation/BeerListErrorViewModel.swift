//
//  BeerListErrorViewModel.swift
//  BeerList
//
//  Created by Tulio Parreiras on 26/01/21.
//

import Foundation

public struct BeerListErrorViewModel {
    public let message: String?
    
    public static var noError: BeerListErrorViewModel {
        return BeerListErrorViewModel(message: nil)
    }
}
