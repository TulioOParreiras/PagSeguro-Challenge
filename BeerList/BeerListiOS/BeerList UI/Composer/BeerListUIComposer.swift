//
//  BeerListUIComposer.swift
//  BeerListiOS
//
//  Created by Tulio Parreiras on 25/01/21.
//

import Foundation
import BeerList

public final class BeerListUIComposer {
    private init() { }
    
    public static func beerListComposedWith(beerListLoader: BeerListLoader, imageLoader: BeerImageDataLoader) -> BeerListViewController {
        let refreshController = BeerListRefreshViewController(beerListLoader: beerListLoader)
        let beerListController = BeerListViewController(refreshController: refreshController)
        refreshController.onRefresh = adaptBeerToCellControllers(forwardingTo: beerListController, loader: imageLoader)
        return beerListController
    }
    
    private static func adaptBeerToCellControllers(forwardingTo controller: BeerListViewController, loader: BeerImageDataLoader) -> ([Beer]) -> Void {
        return { [weak controller] beerList in
            controller?.tableModel = beerList.map { model in
                BeerListCellController(model: model, imageLoader: loader)
            }
        }
    }

}
