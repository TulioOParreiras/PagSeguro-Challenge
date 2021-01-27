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

public final class BeerImageDataLoaderCacheDecorator: BeerImageDataLoader {
    private let decoratee: BeerImageDataLoader
    private let cache: BeerImageDataCache

    public init(decoratee: BeerImageDataLoader, cache: BeerImageDataCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    public func loadImageData(from url: URL, completion: @escaping (BeerImageDataLoader.Result) -> Void) -> BeerImageDataLoaderTask {
        return decoratee.loadImageData(from: url) { [weak self] result in
            completion(result.map { data in
                self?.cache.saveIgnoringResult(data, for: url)
                return data
            })
        }
    }
}

private extension BeerImageDataCache {
    func saveIgnoringResult(_ data: Data, for url: URL) {
        save(data, for: url) { _ in }
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
