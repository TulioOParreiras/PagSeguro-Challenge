//
//  BeerListUIComposer.swift
//  BeerListiOS
//
//  Created by Tulio Parreiras on 25/01/21.
//

import UIKit
import BeerList

public final class BeerListUIComposer {
    private init() { }
    
    public static func beerListComposedWith(beerListLoader: BeerListLoader, imageLoader: BeerImageDataLoader) -> BeerListViewController {
        let presenter = BeerListPresenter(beerListLoader: beerListLoader)
        let refreshController = BeerListRefreshViewController(presenter: presenter)
        let beerListController = BeerListViewController(refreshController: refreshController)
        presenter.loadingView = WeakRefVirtualProxy(object: refreshController)
        presenter.beerListView = BeerListViewAdapter(controller: beerListController, imageLoader: imageLoader)
        return beerListController
    }
    
    private static func adaptBeerToCellControllers(forwardingTo controller: BeerListViewController, loader: BeerImageDataLoader) -> ([Beer]) -> Void {
        return { [weak controller] beerList in
            controller?.tableModel = beerList.map { model in
                BeerListCellController(viewModel:
                                        BeerImageViewModel(model: model, imageLoader: loader, imageTransformer: UIImage.init))
            }
        }
    }

}

private final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?
    
    init(object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: BeerListLoadingView where T: BeerListLoadingView {
    func display(isLoading: Bool) {
        object?.display(isLoading: isLoading)
    }
}

private final class BeerListViewAdapter: BeerListView {
    private weak var controller: BeerListViewController?
    private let imageLoader: BeerImageDataLoader
    
    init(controller: BeerListViewController, imageLoader: BeerImageDataLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func display(beerList: [Beer]) {
        controller?.tableModel = beerList.map { model in
            BeerListCellController(viewModel:
                                    BeerImageViewModel(model: model, imageLoader: imageLoader, imageTransformer: UIImage.init))
        }
    }
}
