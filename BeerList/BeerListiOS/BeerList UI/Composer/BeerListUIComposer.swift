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
        let presenter = BeerListPresenter()
        let presentationAdapter = BeerListLoaderPresentationAdapter(beerListLoader: beerListLoader, presenter: presenter)
        let refreshController = BeerListRefreshViewController(delegate: presentationAdapter)
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
    func display(_ viewModel: BeerListLoadingViewModel) {
        object?.display(viewModel)
    }
}

private final class BeerListViewAdapter: BeerListView {
    private weak var controller: BeerListViewController?
    private let imageLoader: BeerImageDataLoader
    
    init(controller: BeerListViewController, imageLoader: BeerImageDataLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func display(_ viewModel: BeerListViewModel) {
        controller?.tableModel = viewModel.beerList.map { model in
            BeerListCellController(viewModel:
                                    BeerImageViewModel(model: model, imageLoader: imageLoader, imageTransformer: UIImage.init))
        }
    }
}

private final class BeerListLoaderPresentationAdapter: BeerListRefreshViewControllerDelegate {
    private let beerListLoader: BeerListLoader
    private let presenter: BeerListPresenter
    
    init(beerListLoader: BeerListLoader, presenter: BeerListPresenter) {
        self.beerListLoader = beerListLoader
        self.presenter = presenter
    }
    
    func didRequestBeerListRefresh() {
        presenter.didStartLoadingBeerList()
        
        beerListLoader.load { [weak self] result in
            switch result {
            case let .success(beerList):
                self?.presenter.didFinishLoadingBeerList(with: beerList)
            case let .failure(error):
                self?.presenter.didFinishLoadingBeerList(with: error)
            }
        }
    }
}
