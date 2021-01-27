//
//  BeerDetailsView.swift
//  BeerListiOS
//
//  Created by Tulio Parreiras on 26/01/21.
//

import Foundation

public protocol BeerDetailsView {
    associatedtype Image
    
    func display(_ model: BeerDetailsViewModel<Image>)
}
