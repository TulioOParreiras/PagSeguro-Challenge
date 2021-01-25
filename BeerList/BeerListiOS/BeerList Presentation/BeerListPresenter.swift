//
//  BeerListPresenter.swift
//  BeerListiOS
//
//  Created by Tulio Parreiras on 25/01/21.
//

import Foundation
import BeerList

protocol BeerListLoadingView {
    func display(isLoading: Bool)
}

protocol BeerListView {
    func display(beerList: [Beer])
}

final class BeerListPresenter {
    typealias Observer<T> = (T) -> Void
    
    private let beerListLoader: BeerListLoader
    
    init(beerListLoader: BeerListLoader) {
        self.beerListLoader = beerListLoader
    }
    
    var beerListView: BeerListView?
    var loadingView: BeerListLoadingView?
    
    func loadBeerList() {
        loadingView?.display(isLoading: true)
        beerListLoader.load { [weak self] result in
            if let beerList = try? result.get() {
                self?.beerListView?.display(beerList: beerList)
            }
            self?.loadingView?.display(isLoading: false)
        }
    }
}
