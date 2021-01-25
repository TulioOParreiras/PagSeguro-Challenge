//
//  BeerPresenter.swift
//  BeerListiOS
//
//  Created by Tulio Parreiras on 25/01/21.
//

import Foundation
import BeerList

protocol BeerView {
    associatedtype Image
    
    func display(_ model: BeerViewModel<Image>)
}

final class BeerPresenter<View: BeerView, Image> where View.Image == Image {
    private let view: View
    private let imageTransformer: (Data) -> Image?
    
    init(view: View, imageTransformer: @escaping(Data) -> Image?) {
        self.view = view
        self.imageTransformer = imageTransformer
    }
    
    func didStartLoadingImageData(for model: Beer) {
        view.display(BeerViewModel(
            name: model.name,
            ibuValue: model.ibu,
            image: nil,
            isLoading: true,
            shouldRetry: false
        ))
    }
    
    private struct InvalidImageDataError: Error { }
    
    func didFinishLoadingImageData(with data: Data, for model: Beer) {
        guard let image = imageTransformer(data) else {
            return didFinishLoadingImageData(with: InvalidImageDataError(), for: model)
        }
        
        view.display(BeerViewModel(
            name: model.name,
            ibuValue: model.ibu,
            image: image,
            isLoading: false,
            shouldRetry: false
        ))
    }
    
    func didFinishLoadingImageData(with error: Error, for model: Beer) {
        view.display(BeerViewModel(
            name: model.name,
            ibuValue: model.ibu,
            image: nil,
            isLoading: false,
            shouldRetry: true
        ))
    }
}
