//
//  BeerListViewAdapter.swift
//  BeerListiOS
//
//  Created by Tulio Parreiras on 25/01/21.
//

import UIKit
import BeerList
import BeerListiOS

final class BeerListViewAdapter: BeerListView {
    private weak var controller: BeerListViewController?
    private let imageLoader: BeerImageDataLoader
    private let selection: (Beer) -> Void
    
    init(controller: BeerListViewController,
         imageLoader: BeerImageDataLoader,
         selection: @escaping (Beer) -> Void) {
        self.controller = controller
        self.imageLoader = imageLoader
        self.selection = selection
    }
    
    func display(_ viewModel: BeerListViewModel) {
        controller?.display(viewModel.beerList.map { model in
            let adapter = BeerDataLoaderPresentationAdapter<WeakRefVirtualProxy<BeerCellController>, UIImage>(model: model, imageLoader: imageLoader)
            let view = BeerCellController(delegate: adapter,
                                          selection: { [weak self] in
                                            self?.selection(model)
                                          })
            
            adapter.presenter = BeerPresenter(
                view: WeakRefVirtualProxy(view),
                imageTransformer: UIImage.init
            )
            return view
        })
    }
}
