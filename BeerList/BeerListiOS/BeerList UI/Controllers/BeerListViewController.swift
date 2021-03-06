//
//  BeerListViewController.swift
//  BeerListiOS
//
//  Created by Tulio Parreiras on 24/01/21.
//

import UIKit
import BeerList

public protocol BeerListViewControllerDelegate {
    func didRequestBeerListRefresh()
}

final public class BeerListViewController: UITableViewController, UITableViewDataSourcePrefetching, BeerListLoadingView, BeerListErrorView {
    @IBOutlet private(set) public var errorView: ErrorView!
    
    private var loadingControllers = [IndexPath: BeerCellController]()
    private var tableModel: [BeerCellController] = [] {
        didSet { tableView.reloadData() }
    }
    public var delegate: BeerListViewControllerDelegate?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        refresh()
        setupErrorView()
    }
    
    private func setupErrorView() {
        view.addSubview(errorView)
        errorView.frame = view.frame
    }
    
    @IBAction func refresh() {
        delegate?.didRequestBeerListRefresh()
    }
    
    public func display(_ cellControllers: [BeerCellController]) {
        loadingControllers = [:]
        tableModel = cellControllers
    }
    
    public func display(_ viewModel: BeerListLoadingViewModel) {
        viewModel.isLoading ? refreshControl?.beginRefreshing() : refreshControl?.endRefreshing()
    }
    
    public func display(_ viewModel: BeerListErrorViewModel) {
        errorView.message = viewModel.message
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableModel[indexPath.row].selection()
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
        let controller = tableModel[indexPath.row]
        loadingControllers[indexPath] = controller
        return controller
    }
    
    private func cancelCellControllerLoad(forRowAt indexPath: IndexPath) {
        loadingControllers[indexPath]?.cancelLoad()
        loadingControllers[indexPath] = nil
    }
}
