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

public protocol BeerListErrorView {
    func display(_ viewModel: BeerListErrorViewModel)
}

public final class BeerListPresenter {
    private let beerListView: BeerListView
    private let loadingView: BeerListLoadingView
    private let errorView: BeerListErrorView
    
    private var beerListLoadError: String {
        return NSLocalizedString("BEER_LIST_CONNECTION_ERROR",
                                 tableName: "BeerList",
                                 bundle: Bundle(for: BeerListPresenter.self),
                                 comment: "Error message presented when the beer list load from server fail")
    }
    
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
    
    public func didFinishLoadingBeerList(with error: Error) {
        errorView.display(.error(message: beerListLoadError))
        loadingView.display(BeerListLoadingViewModel(isLoading: false))
    }
}
