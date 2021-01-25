//
//  BeerListViewControllerTests.swift
//  BeerListiOSTests
//
//  Created by Tulio Parreiras on 24/01/21.
//

import XCTest
import BeerListiOS
import BeerList

class BeerListViewControllerTests: XCTestCase {

    func test_loadBeerListActions_requestBeerListFromLoader() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadCallCount, 0, "Expect no loading requests before view is loaded")
         
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCallCount, 1, "Expect a loading request once view is loaded")
        
        sut.simulateUserInitiatedBeerListReload()
        XCTAssertEqual(loader.loadCallCount, 2, "Expect another loading request once user initiates a load")
        
        sut.simulateUserInitiatedBeerListReload()
        XCTAssertEqual(loader.loadCallCount, 3, "Expect a third loading request once user initiates another load")
    }
    
    func test_loadingBeerListIndicator_isVisibleWhileLoadingBeerList() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expect loading indicator once view is loaded")
        
        loader.completeBeerListLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expect no loading indicator once loading is complete")
        
        sut.simulateUserInitiatedBeerListReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expect loading indicator once user initiates a reload")
        
        loader.completeBeerListLoading(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expect no loading indicator once user initiated loading is complete")
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
        private var completions = [(LoadResponse)]()
        var loadCallCount: Int {
            completions.count
        }
        
        func load(completion: @escaping LoadResponse) {
            completions.append(completion)
        }
        
        func completeBeerListLoading(at index: Int = 0) {
            completions[index](.success([]))
        }
    }

}

private extension BeerListViewController {
    
    func simulateUserInitiatedBeerListReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    var isShowingLoadingIndicator: Bool {
        return refreshControl?.isRefreshing == true
    }
}

private extension UIRefreshControl {
    
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
    
}
