//
//  BeerListViewControllerTests.swift
//  BeerListiOSTests
//
//  Created by Tulio Parreiras on 24/01/21.
//

import XCTest

final class BeerListViewController {
    init(loader: BeerListViewControllerTests.LoaderSpy) {
        
    }
}

class BeerListViewControllerTests: XCTestCase {

    func test_init_doesNotLoadBeerList() {
        let loader = LoaderSpy()
        _ = BeerListViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    // MARK: - Helpers
    
    class LoaderSpy {
        private(set) var loadCallCount: Int = 0
    }

}
