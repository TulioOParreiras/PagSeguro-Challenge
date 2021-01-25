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
    private let beerListView: BeerListView
    private let loadingView: BeerListLoadingView
    
    init(beerListView: BeerListView, loadingView: BeerListLoadingView) {
        self.beerListView = beerListView
        self.loadingView = loadingView
    }
    
    func didStartLoadingBeerList() {
        loadingView.display(BeerListLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingBeerList(with beerList: [Beer]) {
        beerListView.display(BeerListViewModel(beerList: beerList))
        loadingView.display(BeerListLoadingViewModel(isLoading: false))
    }
    
    func didFinishLoadingBeerList(with error: Error) {
        loadingView.display(BeerListLoadingViewModel(isLoading: false))
    }
}
