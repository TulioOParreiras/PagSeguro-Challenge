//
//  BeerListViewAdapter.swift
//  BeerListiOS
//
//  Created by Tulio Parreiras on 25/01/21.
//

import UIKit

final class BeerListViewAdapter: BeerListView {
    private weak var controller: BeerListViewController?
    private let imageLoader: BeerImageDataLoader
    
    init(controller: BeerListViewController, imageLoader: BeerImageDataLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func display(_ viewModel: BeerListViewModel) {
        controller?.tableModel = viewModel.beerList.map { model in
            let adapter = BeerDataLoaderPresentationAdapter<WeakRefVirtualProxy<BeerCellController>, UIImage>(model: model, imageLoader: imageLoader)
            let view = BeerCellController(delegate: adapter)
            
            adapter.presenter = BeerPresenter(
                view: WeakRefVirtualProxy(view),
                imageTransformer: UIImage.init
            )
            return view
        }
    }
}
