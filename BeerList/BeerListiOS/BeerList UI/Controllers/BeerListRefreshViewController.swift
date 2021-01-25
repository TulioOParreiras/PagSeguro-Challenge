//
//  BeerListRefreshViewController.swift
//  BeerListiOS
//
//  Created by Tulio Parreiras on 25/01/21.
//

import UIKit

public final class BeerListRefreshViewController: NSObject, BeerListLoadingView {
    private(set) lazy var view: UIRefreshControl = loadView(UIRefreshControl())
    private let loadBeerList: () -> Void
    
    init(loadBeerList: @escaping () -> Void) {
        self.loadBeerList = loadBeerList
    }
    
    @objc func refresh() {
        self.loadBeerList()
    }
    
    private func loadView(_ view: UIRefreshControl) -> UIRefreshControl {
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
    
    func display(_ viewModel: BeerListLoadingViewModel) {
        viewModel.isLoading ? view.beginRefreshing() : view.endRefreshing()
    }
}
