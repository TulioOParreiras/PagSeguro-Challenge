//
//  BeerDetailsUIComposer.swift
//  BeerListApp
//
//  Created by Tulio Parreiras on 26/01/21.
//

import UIKit
import BeerList
import BeerListiOS

public final class BeerDetailsUIComposer {
    private init() { }

    public static func beerDetailsComposedWith(beer: Beer, imageLoader: BeerImageDataLoader) -> BeerDetailsViewController {
        let loader = MainQueueDispatchDecorator(decoratee: imageLoader)
        let presentationAdapter = BeerDetailsImageLoaderPresentationAdapter<WeakRefVirtualProxy<BeerDetailsViewController>, UIImage>(beer: beer, imageLoader: loader)

        let beerDetailsController = BeerDetailsViewController(delegate: presentationAdapter)
        presentationAdapter.presenter = BeerDetailsPresenter(view: WeakRefVirtualProxy(beerDetailsController), imageTransformer: UIImage.init)
        
        return beerDetailsController
    }
}

