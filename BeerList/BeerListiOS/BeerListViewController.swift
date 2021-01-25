//
//  BeerListViewController.swift
//  BeerListiOS
//
//  Created by Tulio Parreiras on 24/01/21.
//

import UIKit
import BeerList

public protocol BeerImageDataLoader {
    func loadImageData(from url: URL)
    func cancelImageDataLoad(from url: URL)
}

final public class BeerListViewController: UITableViewController {
    private var beerListLoader: BeerListLoader?
    private var imageLoader: BeerImageDataLoader?
    private var tableModel: [Beer] = []
    
    public convenience init(beerListLoader: BeerListLoader, imageLoader: BeerImageDataLoader ) {
        self.init()
        self.beerListLoader = beerListLoader
        self.imageLoader = imageLoader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        load()
    }
    
    @objc private func load() {
        refreshControl?.beginRefreshing()
        beerListLoader?.load { [weak self] result in
            if let beerList = try? result.get() {
                self?.tableModel = beerList
                self?.tableView.reloadData()
            }
            self?.refreshControl?.endRefreshing()
        }
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = tableModel[indexPath.row]
        let cell = BeerCell()
        cell.ibuLabel.isHidden = cellModel.ibu == nil
        cell.ibuLabel.text = String(describing: cellModel.ibu ?? 0)
        cell.nameLabel.text = cellModel.name
        imageLoader?.loadImageData(from: cellModel.imageURL)
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cellModel = tableModel[indexPath.row]
        imageLoader?.cancelImageDataLoad(from: cellModel.imageURL)
    }
}
