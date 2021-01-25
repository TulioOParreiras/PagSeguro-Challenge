//
//  BeerListViewController.swift
//  BeerListiOS
//
//  Created by Tulio Parreiras on 24/01/21.
//

import UIKit
import BeerList

final public class BeerListViewController: UITableViewController {
    private var loader: BeerListLoader?
    private var tableModel: [Beer] = []
    
    public convenience init(loader: BeerListLoader) {
        self.init()
        self.loader = loader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        load()
    }
    
    @objc private func load() {
        refreshControl?.beginRefreshing()
        loader?.load { [weak self] result in
            self?.tableModel = (try? result.get()) ?? []
            self?.tableView.reloadData()
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
        return cell
    }
}
