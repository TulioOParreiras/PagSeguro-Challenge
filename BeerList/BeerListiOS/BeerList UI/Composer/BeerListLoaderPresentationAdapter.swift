//
//  BeerListLoaderPresentationAdapter.swift
//  BeerListiOS
//
//  Created by Tulio Parreiras on 25/01/21.
//

import Foundation
import BeerList

final class BeerListLoaderPresentationAdapter: BeerListViewControllerDelegate {
    private let beerListLoader: BeerListLoader
    var presenter: BeerListPresenter?
    
    init(beerListLoader: BeerListLoader) {
        self.beerListLoader = beerListLoader
    }
    
    func didRequestBeerListRefresh() {
        presenter?.didStartLoadingBeerList()
        
        beerListLoader.load { [weak self] result in
            switch result {
            case let .success(beerList):
                self?.presenter?.didFinishLoadingBeerList(with: beerList)
            case let .failure(error):
                self?.presenter?.didFinishLoadingBeerList(with: error)
            }
        }
    }
}
