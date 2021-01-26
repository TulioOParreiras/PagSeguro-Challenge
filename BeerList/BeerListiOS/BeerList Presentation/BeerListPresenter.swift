//
//  BeerListPresenter.swift
//  BeerListiOS
//
//  Created by Tulio Parreiras on 25/01/21.
//

import Foundation
import BeerList

protocol BeerListLoadingView {
    func display(_ viewModel: BeerListLoadingViewModel)
}

protocol BeerListView {
    func display(_ viewModel: BeerListViewModel)
}

struct BeerListErrorViewModel {
    let message: String?
    
    static var noError: BeerListErrorViewModel {
        return BeerListErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> BeerListErrorViewModel {
        return BeerListErrorViewModel(message: message)
    }

}

protocol BeerListErrorView {
    func display(_ viewModel: BeerListErrorViewModel)
}

final class BeerListPresenter {
    private let beerListView: BeerListView
    private let loadingView: BeerListLoadingView
    private let errorView: BeerListErrorView
    
    init(beerListView: BeerListView, loadingView: BeerListLoadingView, errorView: BeerListErrorView) {
        self.beerListView = beerListView
        self.loadingView = loadingView
        self.errorView = errorView
    }
    
    static var title: String {
        return NSLocalizedString("BEER_LIST_VIEW_TITLE",
                                 tableName: "BeerList",
                                 bundle: Bundle(for: BeerListPresenter.self),
                                 comment: "Title for the beer list view")
    }
    
    private var beerListLoadError: String {
        return NSLocalizedString("BEER_LIST_CONNECTION_ERROR",
                                 tableName: "BeerList",
                                 bundle: Bundle(for: BeerListPresenter.self),
                                 comment: "Error message presented when the beer list load from server fail")
    }
    
    func didStartLoadingBeerList() {
        errorView.display(.noError)
        loadingView.display(BeerListLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingBeerList(with beerList: [Beer]) {
        beerListView.display(BeerListViewModel(beerList: beerList))
        loadingView.display(BeerListLoadingViewModel(isLoading: false))
    }
    
    func didFinishLoadingBeerList(with error: Error) {
        errorView.display(.error(message: beerListLoadError))
        loadingView.display(BeerListLoadingViewModel(isLoading: false))
    }
}
