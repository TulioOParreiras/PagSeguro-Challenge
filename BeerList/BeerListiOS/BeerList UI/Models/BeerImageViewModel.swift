//
//  BeerImageViewModel.swift
//  BeerListiOS
//
//  Created by Tulio Parreiras on 25/01/21.
//

import UIKit
import BeerList

final class BeerImageViewModel {
    typealias Observer<T> = (T) -> Void
    
    private var task: BeerImageDataLoaderTask?
    private let model: Beer
    private let imageLoader: BeerImageDataLoader
    
    init(model: Beer, imageLoader: BeerImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    var name: String {
        return model.name
    }
    
    var ibu: String?  {
        guard let ibu = model.ibu else { return nil }
        return String(describing: ibu)
    }
    
    var hasIbu: Bool {
        return ibu != nil
    }
    
    var onImageLoad: Observer<UIImage>?
    var onImageLoadingStateChange: Observer<Bool>?
    var onShouldRetryImageLoadStateChange: Observer<Bool>?
    
    func loadImageData() {
        onImageLoadingStateChange?(true)
        onShouldRetryImageLoadStateChange?(false)
        task = imageLoader.loadImageData(from: model.imageURL) { [weak self] result in
            self?.handle(result)
        }
    }
    
    private func handle(_ result: BeerImageDataLoader.Result) {
        if let image = (try? result.get()).flatMap(UIImage.init) {
            onImageLoad?(image)
        } else {
            onShouldRetryImageLoadStateChange?(true)
        }
        onImageLoadingStateChange?(false)
    }
    
    func cancelImageDataLoad() {
        task?.cancel()
        task = nil
    }
}
