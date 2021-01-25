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
        XCTAssertEqual(loader.loadBeerListCallCount, 0, "Expect no loading requests before view is loaded")
         
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadBeerListCallCount, 1, "Expect a loading request once view is loaded")
        
        sut.simulateUserInitiatedBeerListReload()
        XCTAssertEqual(loader.loadBeerListCallCount, 2, "Expect another loading request once user initiates a load")
        
        sut.simulateUserInitiatedBeerListReload()
        XCTAssertEqual(loader.loadBeerListCallCount, 3, "Expect a third loading request once user initiates another load")
    }
    
    func test_loadingBeerListIndicator_isVisibleWhileLoadingBeerList() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expect loading indicator once view is loaded")
        
        loader.completeBeerListLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expect no loading indicator once loading completes with success")
        
        sut.simulateUserInitiatedBeerListReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expect loading indicator once user initiates a reload")
        
        loader.completeBeerListLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expect no loading indicator once user initiated loading completes with error")
    }
    
    func test_loadBeerListCompletion_rendersSuccessfullyLoadedBeers() {
        let beer0 = makeBeer(name: "A name", ibu: 1)
        let beer1 = makeBeer(name: "Another name", ibu: nil)
        let beer2 = makeBeer(name: "Still other name", ibu: 2.5)
        let beer3 = makeBeer(name: "A brand new name", ibu: nil)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        assertThat(sut, isRendering: [])
        XCTAssertEqual(sut.numberOfRenderedBeerCells(), 0)
        
        loader.completeBeerListLoading(with: [beer0], at: 0)
        assertThat(sut, isRendering: [beer0])
        
        sut.simulateUserInitiatedBeerListReload()
        let beerList = [beer0, beer1, beer2, beer3]
        loader.completeBeerListLoading(with: beerList, at: 1)
        assertThat(sut, isRendering: beerList)
    }
    
    func test_loadBeerListCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let beer0 = makeBeer(name: "A name", ibu: 1)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        assertThat(sut, isRendering: [])
        XCTAssertEqual(sut.numberOfRenderedBeerCells(), 0)
        
        loader.completeBeerListLoading(with: [beer0], at: 0)
        assertThat(sut, isRendering: [beer0])
        
        sut.simulateUserInitiatedBeerListReload()
        loader.completeBeerListLoadingWithError(at: 1)
        assertThat(sut, isRendering: [beer0])
    }
    
    func test_beerCell_loadsImageURLWhenVisible() {
        let beer0 = makeBeer(imageURL: URL(string: "https://a-url.com")!)
        let beer1 = makeBeer(imageURL: URL(string: "https://any-url.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeBeerListLoading(with: [beer0, beer1])
        
        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image URL requests until views become visible")
        
        sut.simulateBeerCellVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [beer0.imageURL], "Expected first image URL request once first view becomes visible")
        
        sut.simulateBeerCellVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [beer0.imageURL, beer1.imageURL], "Expected second image URL request once second view also becomes visible")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: BeerListViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = BeerListViewController(beerListLoader: loader, imageLoader: loader)
        trackForMemoryLeaks(loader)
        trackForMemoryLeaks(sut)
        return (sut, loader)
    }
    
    private func assertThat(_ sut: BeerListViewController, isRendering beerList: [Beer], file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(sut.numberOfRenderedBeerCells(), beerList.count, "Expected \(beerList.count) beers, got \(sut.numberOfRenderedBeerCells()) instead", file: file, line: line)
        
        beerList.enumerated().forEach { index, beer in
            assertThat(sut, hasViewConfiguredFor: beer, at: index, file: file, line: line)
        }
    }
    
    private func assertThat(_ sut: BeerListViewController, hasViewConfiguredFor beer: Beer, at index: Int, file: StaticString = #file, line: UInt = #line) {
        let view = sut.beerCell(at: index)
        
        guard let cell = view as? BeerCell else {
            return XCTFail("Expected \(BeerCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
        }
        
        let shouldIbuBeVisible = beer.ibu != nil
        XCTAssertEqual(cell.isShowingIbu, shouldIbuBeVisible, "Expected `isShowingIbu` to be \(shouldIbuBeVisible) for beer cell at index (\(index))", file: file, line: line)
        
        XCTAssertEqual(cell.nameText, beer.name, "Expected name text to be \(beer.name) for beer cell at index (\(index))", file: file, line: line)
    }
    
    private func makeBeer(name: String = "A name", imageURL: URL = URL(string: "https://a-url.com")!, ibu: Double? = nil) -> Beer {
        return Beer(id: Int.random(in: 0...100), name: name, tagline: "a tagline", description: "a description", imageURL: imageURL, abv: Double.random(in: 1...10), ibu: ibu)
    }
    
    class LoaderSpy: BeerListLoader, BeerImageDataLoader {
        
        // MARK: - BeerListLoader
        
        private var beerListRequests = [(LoadResponse)]()
        var loadBeerListCallCount: Int {
            return beerListRequests.count
        }
        
        func load(completion: @escaping LoadResponse) {
            beerListRequests.append(completion)
        }
        
        func completeBeerListLoading(with beers: [Beer] = [], at index: Int = 0) {
            beerListRequests[index](.success(beers))
        }
        
        func completeBeerListLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "a domain", code: 1)
            beerListRequests[index](.failure(error))
        }
        
        // MARK: - BeerImageDataLoader
        
        var loadedImageURLs: [URL] = []
        
        func loadImageData(from url: URL) {
            loadedImageURLs.append(url)
        }
    }

}

private extension BeerListViewController {
    
    func simulateUserInitiatedBeerListReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    func simulateBeerCellVisible(at index: Int) {
        _ = beerCell(at: index)
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

private extension BeerCell {
    var isShowingIbu: Bool {
        return !ibuLabel.isHidden
    }
    
    var nameText: String? {
        return nameLabel.text
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
