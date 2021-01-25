//
//  BeerListViewControllerTests.swift
//  BeerListiOSTests
//
//  Created by Tulio Parreiras on 24/01/21.
//

import XCTest
import UIKit
import BeerList

final class BeerListViewController: UITableViewController {
    private var loader: BeerListLoader?
    
    convenience init(loader: BeerListLoader) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        refreshControl?.beginRefreshing()
        load()
    }
    
    @objc private func load() {
        loader?.load { _ in }
    }
}

class BeerListViewControllerTests: XCTestCase {

    func test_init_doesNotLoadBeerList() {
        let (_, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    func test_viewDidLoad_doesLoadBeerList() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCallCount, 1)
    }
    
    func test_pullToRefresh_loadsBeerList() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        sut.simulatePullToRefresh()
        XCTAssertEqual(loader.loadCallCount, 2)
        
        sut.simulatePullToRefresh()
        XCTAssertEqual(loader.loadCallCount, 3)
    }
    
    func test_viewDidLoad_showsLoadingIndicator() {
        let (sut, _) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.refreshControl?.isRefreshing, true)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: BeerListViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = BeerListViewController(loader: loader)
        trackForMemoryLeaks(loader)
        trackForMemoryLeaks(sut)
        return (sut, loader)
    }
    
    class LoaderSpy: BeerListLoader {
        private(set) var loadCallCount: Int = 0
        
        func load(completion: @escaping LoadResponse) {
            loadCallCount += 1
        }
    }

}

extension BeerListViewController {
    
    func simulatePullToRefresh() {
        refreshControl?.allTargets.forEach { target in
            refreshControl?.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
    
}
