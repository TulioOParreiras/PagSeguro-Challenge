//
//  BeerListRefreshViewController.swift
//  BeerListiOS
//
//  Created by Tulio Parreiras on 25/01/21.
//

import UIKit

protocol BeerListRefreshViewControllerDelegate {
    func didRequestBeerListRefresh()
}

public final class BeerListRefreshViewController: NSObject, BeerListLoadingView {
    @IBOutlet weak var view: UIRefreshControl?
    var delegate: BeerListRefreshViewControllerDelegate?
    
    @IBAction func refresh() {
        delegate?.didRequestBeerListRefresh()
    }
    
    func display(_ viewModel: BeerListLoadingViewModel) {
        viewModel.isLoading ? view?.beginRefreshing() : view?.endRefreshing()
    }
}
