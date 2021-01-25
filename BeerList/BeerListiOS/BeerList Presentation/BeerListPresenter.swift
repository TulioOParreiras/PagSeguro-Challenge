//
//  BeerListPresenter.swift
//  BeerListiOS
//
//  Created by Tulio Parreiras on 25/01/21.
//

import Foundation
import BeerList

struct BeerListLoadingViewModel {
    let isLoading: Bool
}

protocol BeerListLoadingView {
    func display(_ viewModel: BeerListLoadingViewModel)
}

struct BeerListViewModel {
    let beerList: [Beer]
}

protocol BeerListView {
    func display(_ viewModel: BeerListViewModel)
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
        loadingView?.display(BeerListLoadingViewModel(isLoading: true))
        beerListLoader.load { [weak self] result in
            if let beerList = try? result.get() {
                self?.beerListView?.display(BeerListViewModel(beerList: beerList))
            }
            self?.loadingView?.display(BeerListLoadingViewModel(isLoading: false))
        }
    }
}
