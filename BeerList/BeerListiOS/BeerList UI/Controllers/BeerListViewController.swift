//
//  BeerListViewController.swift
//  BeerListiOS
//
//  Created by Tulio Parreiras on 24/01/21.
//

import UIKit

final public class ErrorView: UIView {
    public var message: String?
}

protocol BeerListViewControllerDelegate {
    func didRequestBeerListRefresh()
}

final public class BeerListViewController: UITableViewController, UITableViewDataSourcePrefetching, BeerListLoadingView, BeerListErrorView {
    @IBOutlet private(set) public var errorView: ErrorView!
    var tableModel: [BeerCellController] = [] {
        didSet { tableView.reloadData() }
    }
    var delegate: BeerListViewControllerDelegate?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        refresh()
    }
    
    @IBAction func refresh() {
        delegate?.didRequestBeerListRefresh()
    }
    
    func display(_ viewModel: BeerListLoadingViewModel) {
        viewModel.isLoading ? refreshControl?.beginRefreshing() : refreshControl?.endRefreshing()
    }
    
    func display(_ viewModel: BeerListErrorViewModel) {
        errorView.message = viewModel.message
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellController(forRowAt: indexPath).view(tableView)
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelCellControllerLoad(forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellController(forRowAt: indexPath).preload()
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelCellControllerLoad)
    }
    
    private func cellController(forRowAt indexPath: IndexPath) -> BeerCellController {
        return tableModel[indexPath.row]
    }
    
    private func cancelCellControllerLoad(forRowAt indexPath: IndexPath) {
        tableModel[indexPath.row].cancelLoad()
    }
}
