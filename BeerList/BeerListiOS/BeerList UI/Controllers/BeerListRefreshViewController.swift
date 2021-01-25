//
//  BeerListRefreshViewController.swift
//  BeerListiOS
//
//  Created by Tulio Parreiras on 25/01/21.
//

import UIKit
import BeerList

public final class BeerListRefreshViewController: NSObject {
    private(set) lazy var view: UIRefreshControl = {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }()
    private let beerListLoader: BeerListLoader
    var onRefresh: (([Beer]) -> Void)?
    
    init(beerListLoader: BeerListLoader) {
        self.beerListLoader = beerListLoader
    }
    
    @objc func refresh() {
        view.beginRefreshing()
        beerListLoader.load { [weak self] result in
            if let beerList = try? result.get() {
                self?.onRefresh?(beerList)
            }
            self?.view.endRefreshing()
        }
    }
}
