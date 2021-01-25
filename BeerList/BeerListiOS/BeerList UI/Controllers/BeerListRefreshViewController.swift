//
//  BeerListRefreshViewController.swift
//  BeerListiOS
//
//  Created by Tulio Parreiras on 25/01/21.
//

import UIKit

public final class BeerListRefreshViewController: NSObject, BeerListLoadingView {
    private(set) lazy var view: UIRefreshControl = loadView(UIRefreshControl())
    private let presenter: BeerListPresenter
    
    init(presenter: BeerListPresenter) {
        self.presenter = presenter
    }
    
    @objc func refresh() {
        self.presenter.loadBeerList()
    }
    
    private func loadView(_ view: UIRefreshControl) -> UIRefreshControl {
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
    
    func display(isLoading: Bool) {
        isLoading ? view.beginRefreshing() : view.endRefreshing()
    }
}
