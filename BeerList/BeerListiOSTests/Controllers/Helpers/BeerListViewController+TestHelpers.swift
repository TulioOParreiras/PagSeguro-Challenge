//
//  BeerListViewController+TestHelpers.swift
//  BeerListiOSTests
//
//  Created by Tulio Parreiras on 25/01/21.
//

import UIKit
import BeerListiOS

extension BeerListViewController {
    
    func simulateUserInitiatedBeerListReload() {
        refreshControl?.simulateEvent(.valueChanged)
    }
    
    @discardableResult
    func simulateBeerCellVisible(at row: Int) -> BeerCell? {
        return beerCell(at: row) as? BeerCell
    }
    
    func simulateBeerCellNotVisible(at row: Int) {
        let view = simulateBeerCellVisible(at: row)
        
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: beerCellsSection)
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)
    }
    
    func simulateBeerCellNearVisible(at row: Int) {
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: beerCellsSection)
        ds?.tableView(tableView, prefetchRowsAt: [index])
    }
    
    func simulateBeerCellNotNearVisible(at row: Int) {
        simulateBeerCellNearVisible(at: row)
        
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: beerCellsSection)
        ds?.tableView?(tableView, cancelPrefetchingForRowsAt: [index])
    }

    
    var isShowingLoadingIndicator: Bool {
        return refreshControl?.isRefreshing == true
    }
    
    func numberOfRenderedBeerCells() -> Int {
        return tableView.numberOfRows(inSection: beerCellsSection)
    }
    
    func beerCell(at row: Int) -> UITableViewCell? {
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: beerCellsSection)
        return ds?.tableView(tableView, cellForRowAt: index)
    }
    
    private var beerCellsSection: Int {
        return 0
    }
}
