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

        let bundle = Bundle(for: BeerDetailsViewController.self)
        let storyboard = UIStoryboard(name: "BeerDetails", bundle: bundle)
        let beerDetailsController = storyboard.instantiateInitialViewController() as! BeerDetailsViewController
        beerDetailsController.delegate = presentationAdapter
        beerDetailsController.title = BeerDetailsPresenter<WeakRefVirtualProxy<BeerDetailsViewController>, UIImage>.title
        presentationAdapter.presenter = BeerDetailsPresenter(view: WeakRefVirtualProxy(beerDetailsController), imageTransformer: UIImage.init)
        
        return beerDetailsController
    }
}

