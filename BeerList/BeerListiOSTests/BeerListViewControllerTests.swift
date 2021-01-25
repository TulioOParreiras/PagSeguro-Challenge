//
//  BeerListViewControllerTests.swift
//  BeerListiOSTests
//
//  Created by Tulio Parreiras on 24/01/21.
//

import XCTest

final class BeerListViewController: UIViewController {
    private var loader: BeerListViewControllerTests.LoaderSpy?
    
    convenience init(loader: BeerListViewControllerTests.LoaderSpy) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loader?.load()
    }
}

class BeerListViewControllerTests: XCTestCase {

    func test_init_doesNotLoadBeerList() {
        let loader = LoaderSpy()
        _ = BeerListViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    func test_viewDidLoad_doesLoadBeerList() {
        let loader = LoaderSpy()
        let sut = BeerListViewController(loader: loader)
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCallCount, 1)
    }
    
    // MARK: - Helpers
    
    class LoaderSpy {
        private(set) var loadCallCount: Int = 0
        
        func load() {
            loadCallCount += 1
        }
    }

}
