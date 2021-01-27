//
//  BeerListUIComposer.swift
//  BeerListiOS
//
//  Created by Tulio Parreiras on 25/01/21.
//

import UIKit
import BeerList
import BeerListiOS

public final class BeerListUIComposer {
    private init() { }
    
    public static func beerListComposedWith(
        beerListLoader: BeerListLoader,
        imageLoader: BeerImageDataLoader,
        selection: @escaping (Beer) -> Void = { _ in }
    ) -> BeerListViewController {
        let presentationAdapter = BeerListLoaderPresentationAdapter(beerListLoader: MainQueueDispatchDecorator(decoratee: beerListLoader))
        
        let beerListController = BeerListViewController.makeWith(
            delegate: presentationAdapter,
            title: BeerListPresenter.title)
        
        presentationAdapter.presenter = BeerListPresenter(
            beerListView: BeerListViewAdapter(
                controller: beerListController,
                imageLoader: MainQueueDispatchDecorator(decoratee: imageLoader),
                selection: selection),
            loadingView: WeakRefVirtualProxy(beerListController),
            errorView: WeakRefVirtualProxy(beerListController))
        return beerListController
    }

}


private extension BeerListViewController {
    static func makeWith(delegate: BeerListViewControllerDelegate, title: String) -> BeerListViewController {
        let bundle = Bundle(for: BeerListViewController.self)
        let storyboard = UIStoryboard(name: "BeerList", bundle: bundle)
        let beerListController = storyboard.instantiateInitialViewController() as! BeerListViewController
        beerListController.delegate = delegate
        beerListController.title = title
        return beerListController
    }
}
