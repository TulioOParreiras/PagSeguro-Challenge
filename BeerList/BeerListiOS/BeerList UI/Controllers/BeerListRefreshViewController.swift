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
    private(set) lazy var view: UIRefreshControl = loadView(UIRefreshControl())
    private let delegate: BeerListRefreshViewControllerDelegate
    
    init(delegate: BeerListRefreshViewControllerDelegate) {
        self.delegate = delegate
    }
    
    @objc func refresh() {
        delegate.didRequestBeerListRefresh()
    }
    
    private func loadView(_ view: UIRefreshControl) -> UIRefreshControl {
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
    
    func display(_ viewModel: BeerListLoadingViewModel) {
        viewModel.isLoading ? view.beginRefreshing() : view.endRefreshing()
    }
}
