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
        refreshController.onRefresh = { [weak beerListController] beerList in
            guard let beerListController = beerListController else { return }
            beerListController.tableModel = beerList.map { model in
                BeerListCellController(model: model, imageLoader: imageLoader)
            }
        }
        return beerListController
    }
}
