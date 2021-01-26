//
//  BeerDataLoaderPresentationAdapter.swift
//  BeerListiOS
//
//  Created by Tulio Parreiras on 25/01/21.
//

import Foundation
import BeerList
import BeerListiOS

final class BeerDataLoaderPresentationAdapter<View: BeerView, Image>: BeerCellControllerDelegate where View.Image == Image {
    private let model: Beer
    private let imageLoader: BeerImageDataLoader
    private var task: BeerImageDataLoaderTask?
    
    var presenter: BeerPresenter<View, Image>?
    
    init(model: Beer, imageLoader: BeerImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    func didRequestImage() {
        presenter?.didStartLoadingImageData(for: model)
        
        let model = self.model
        task = imageLoader.loadImageData(from: model.imageURL, completion: { [weak self] result in
            switch result {
            case let .success(data):
                self?.presenter?.didFinishLoadingImageData(with: data, for: model)
                
            case let .failure(error):
                self?.presenter?.didFinishLoadingImageData(with: error, for: model)
            }
        })
    }
    
    func didCancelImageRequest() {
        task?.cancel()
    }
    
}

