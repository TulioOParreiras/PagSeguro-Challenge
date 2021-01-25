//
//  BeerListViewControllerTests.swift
//  BeerListiOSTests
//
//  Created by Tulio Parreiras on 24/01/21.
//

import XCTest
import UIKit
import BeerList

final class BeerListViewController: UIViewController {
    private var loader: BeerListLoader?
    
    convenience init(loader: BeerListLoader) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
