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
        let viewModel = BeerListViewModel(beerListLoader: beerListLoader)
        let refreshController = BeerListRefreshViewController(viewModel: viewModel)
        let beerListController = BeerListViewController(refreshController: refreshController)
        viewModel.onBeerListLoad = adaptBeerToCellControllers(forwardingTo: beerListController, loader: imageLoader)
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
