//
//  BeerDetailsPresenter.swift
//  BeerList
//
//  Created by Tulio Parreiras on 26/01/21.
//

import Foundation

public protocol BeerDetailsView {
    associatedtype Image
    
    func display(_ model: BeerDetailsViewModel<Image>)
}

public final class BeerDetailsPresenter<View: BeerDetailsView, Image> where View.Image == Image {
    private let view: View
    private let imageTransformer: (Data) -> Image?

    public init(view: View, imageTransformer: @escaping(Data) -> Image?) {
        self.view = view
        self.imageTransformer = imageTransformer
    }
    
    public func didStartLoadingImageData(for model: Beer) {
        view.display(BeerDetailsViewModel(
            name: model.name,
            description: model.description,
            ibuValue: model.ibu,
            abvValue: model.abv,
            tagline: model.tagline,
            image: nil,
            isLoading: true,
            shouldRetry: false
        ))
    }
    
    public func didFinishLoadingImageData(with data: Data, for model: Beer) {
        let image = imageTransformer(data)
        view.display(BeerDetailsViewModel(
            name: model.name,
            description: model.description,
            ibuValue: model.ibu,
            abvValue: model.abv,
            tagline: model.tagline,
            image: image,
            isLoading: false,
            shouldRetry: image == nil
        ))
    }
    
    public func didFinishLoadingImageData(with error: Error, for model: Beer) {
        view.display(BeerDetailsViewModel(
            name: model.name,
            description: model.description,
            ibuValue: model.ibu,
            abvValue: model.abv,
            tagline: model.tagline,
            image: nil,
            isLoading: false,
            shouldRetry: true
        ))
    }
}
