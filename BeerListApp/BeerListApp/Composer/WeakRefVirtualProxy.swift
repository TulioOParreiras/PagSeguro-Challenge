//
//  WeakRefVirtualProxy.swift
//  BeerListiOS
//
//  Created by Tulio Parreiras on 25/01/21.
//

import UIKit
import BeerList

final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?
    
    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: BeerListLoadingView where T: BeerListLoadingView {
    func display(_ viewModel: BeerListLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: BeerView where T: BeerView, T.Image == UIImage {
    func display(_ model: BeerViewModel<UIImage>) {
        object?.display(model)
    }
}

extension WeakRefVirtualProxy: BeerListErrorView where T: BeerListErrorView {
    func display(_ viewModel: BeerListErrorViewModel) {
        object?.display(viewModel)
    }
}
