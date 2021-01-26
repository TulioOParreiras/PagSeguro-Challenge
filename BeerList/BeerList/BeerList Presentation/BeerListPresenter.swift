//
//  BeerListPresenter.swift
//  BeerList
//
//  Created by Tulio Parreiras on 26/01/21.
//

import Foundation

public protocol BeerListView {
    func display(_ viewModel: BeerListViewModel)
}

public protocol BeerListLoadingView {
    func display(_ viewModel: BeerListLoadingViewModel)
}

public struct BeerListErrorViewModel {
    public let message: String?
    
    public static var noError: BeerListErrorViewModel {
        return BeerListErrorViewModel(message: nil)
    }
}

public protocol BeerListErrorView {
    func display(_ viewModel: BeerListErrorViewModel)
}

public final class BeerListPresenter {
    private let beerListView: BeerListView
    private let loadingView: BeerListLoadingView
    private let errorView: BeerListErrorView
    
    public init(beerListView: BeerListView, loadingView: BeerListLoadingView,errorView: BeerListErrorView) {
        self.beerListView = beerListView
        self.loadingView = loadingView
        self.errorView = errorView
    }
    
    public func didStartLoadingBeerList() {
        errorView.display(.noError)
        loadingView.display(BeerListLoadingViewModel(isLoading: true))
    }
    
    public func didFinishLoadingBeerList(with beerList: [Beer]) {
        beerListView.display(BeerListViewModel(beerList: beerList))
        loadingView.display(BeerListLoadingViewModel(isLoading: false))
    }
}
