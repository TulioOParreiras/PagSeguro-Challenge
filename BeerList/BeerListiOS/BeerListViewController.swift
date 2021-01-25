//
//  BeerListViewController.swift
//  BeerListiOS
//
//  Created by Tulio Parreiras on 24/01/21.
//

import UIKit
import BeerList

public protocol BeerImageDataLoaderTask {
    func cancel()
}

public protocol BeerImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    func loadImageData(from url: URL, completion: @escaping(Result) -> Void) -> BeerImageDataLoaderTask
}

final public class BeerListViewController: UITableViewController {
    private var beerListLoader: BeerListLoader?
    private var imageLoader: BeerImageDataLoader?
    private var tableModel: [Beer] = []
    private var tasks = [IndexPath: BeerImageDataLoaderTask]()
    
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
        cell.beerImageView.image = nil
        cell.beerImageReturnButton.isHidden = true
        cell.imageContainer.startShimmering()
        let loadImage = { [weak cell, weak self] in
            guard let self = self else { return }
            self.tasks[indexPath] = self.imageLoader?.loadImageData(from: cellModel.imageURL) { [weak cell] result in
                let data = try? result.get()
                let image = data.map(UIImage.init) ?? nil
                cell?.beerImageView.image = image
                cell?.beerImageReturnButton.isHidden = image != nil
                cell?.imageContainer.stopShimmering()
            }
        }
        
        cell.onRetry = loadImage
        loadImage()
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tasks[indexPath]?.cancel()
        tasks[indexPath] = nil
    }
}
