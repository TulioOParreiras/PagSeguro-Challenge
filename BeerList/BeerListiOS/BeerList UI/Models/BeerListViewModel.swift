//
//  BeerListViewModel.swift
//  BeerListiOS
//
//  Created by Tulio Parreiras on 25/01/21.
//

import Foundation
import BeerList

final class BeerListViewModel {
    private let beerListLoader: BeerListLoader
    
    init(beerListLoader: BeerListLoader) {
        self.beerListLoader = beerListLoader
    }
    
    var onChange: ((BeerListViewModel) -> Void)?
    var onBeerListLoad: (([Beer]) -> Void)?
    
    var isLoading: Bool = false {
        didSet { onChange?(self) }
    }
    
    func loadBeerList() {
        isLoading = true
        beerListLoader.load { [weak self] result in
            if let beerList = try? result.get() {
                self?.onBeerListLoad?(beerList)
            }
            self?.isLoading = false
        }
    }
}
