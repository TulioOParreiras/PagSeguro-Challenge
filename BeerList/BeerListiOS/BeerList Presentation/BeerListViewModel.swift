//
//  BeerListViewModel.swift
//  BeerListiOS
//
//  Created by Tulio Parreiras on 25/01/21.
//

import Foundation
import BeerList

final class BeerListViewModel {
    typealias Observer<T> = (T) -> Void
    
    private let beerListLoader: BeerListLoader
    
    init(beerListLoader: BeerListLoader) {
        self.beerListLoader = beerListLoader
    }
    
    var onLoadingStateChange: Observer<Bool>?
    var onBeerListLoad: Observer<[Beer]>?
    
    func loadBeerList() {
        onLoadingStateChange?(true)
        beerListLoader.load { [weak self] result in
            if let beerList = try? result.get() {
                self?.onBeerListLoad?(beerList)
            }
            self?.onLoadingStateChange?(false)
        }
    }
}
