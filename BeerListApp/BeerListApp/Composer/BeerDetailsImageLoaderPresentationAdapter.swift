//
//  BeerDetailsImageLoaderPresentationAdapter.swift
//  BeerListApp
//
//  Created by Tulio Parreiras on 26/01/21.
//

import Foundation

final class BeerDetailsImageLoaderPresentationAdapter<View: BeerDetailsView, Image>: BeerDetailsViewControllerDelegate where View.Image == Image {
    private let imageLoader: BeerImageDataLoader
    private let beer: Beer
    var presenter: BeerDetailsPresenter<View, Image>?
    
    init(beer: Beer, imageLoader: BeerImageDataLoader) {
        self.beer = beer
        self.imageLoader = imageLoader
    }
    
    func didRequestBeerImageLoad() {
        let model = beer
        presenter?.didStartLoadingImageData(for: model)
        _ = imageLoader.loadImageData(from: beer.imageURL) { [weak self] result in
            switch result {
            case let .success(data):
                self?.presenter?.didFinishLoadingImageData(with: data, for: model)
            case let .failure(error):
                self?.presenter?.didFinishLoadingImageData(with: error, for: model)
            }
        }
    }
}
