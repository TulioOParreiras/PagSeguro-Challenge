//
//  BeerListViewController.swift
//  BeerListiOS
//
//  Created by Tulio Parreiras on 24/01/21.
//

import UIKit
import BeerList

final public class BeerListViewController: UITableViewController, UITableViewDataSourcePrefetching {
    private var refreshController: BeerListRefreshViewController?
    private var imageLoader: BeerImageDataLoader?
    private var tableModel: [Beer] = [] {
        didSet { tableView.reloadData() }
    }
    private var cellControllers = [IndexPath: BeerListCellController]()
    
    public convenience init(beerListLoader: BeerListLoader, imageLoader: BeerImageDataLoader ) {
        self.init()
        self.refreshController = BeerListRefreshViewController(beerListLoader: beerListLoader)
        self.imageLoader = imageLoader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        tableView.refreshControl = refreshController?.view
        refreshController?.onRefresh = { [weak self] beerList in
            self?.tableModel = beerList
        }
        tableView.prefetchDataSource = self
        refreshController?.refresh()
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellController(forRowAt: indexPath).view()
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        removeCellController(forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellController(forRowAt: indexPath).preload()
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(removeCellController)
    }
    
    private func cellController(forRowAt indexPath: IndexPath) -> BeerListCellController {
        let cellModel = tableModel[indexPath.row]
        let cellController = BeerListCellController(model: cellModel, imageLoader: imageLoader!)
        cellControllers[indexPath] = cellController
        return cellController
    }
    
    private func removeCellController(forRowAt indexPath: IndexPath) {
        cellControllers[indexPath] = nil
    }
}
