//
//  BeerListUIIntegrationsTests.swift
//  BeerListiOSTests
//
//  Created by Tulio Parreiras on 24/01/21.
//

import XCTest
import BeerListiOS
import BeerList
import BeerListApp

class BeerListUIIntegrationsTests: XCTestCase {
    
    func test_beerListView_hasTitle() {
        let (sut, _) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.title, localized("BEER_LIST_VIEW_TITLE"))
    }
    
    func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let table = "BeerList"
        let bundle = Bundle(for: BeerListPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }


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
    
    func test_loadBeerListCompletion_rendersSuccessfullyLoadedEmptyBeersAfterNonEmptyBeers() {
        let beer0 = makeBeer()
        let beer1 = makeBeer()
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeBeerListLoading(with: [beer0, beer1], at: 0)
        assertThat(sut, isRendering: [beer0, beer1])
        
        sut.simulateUserInitiatedBeerListReload()
        loader.completeBeerListLoading(with: [], at: 1)
        assertThat(sut, isRendering: [])
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
    
    func test_loadBeerListCompletion_rendersErrorMessageOnErrorUntilNextReload() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.errorMessage, nil)
        
        loader.completeBeerListLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, localized("BEER_LIST_CONNECTION_ERROR"))

        sut.simulateUserInitiatedBeerListReload()
        XCTAssertEqual(sut.errorMessage, nil)
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
    
    func test_beerCell_cancelsImageURLWhenNotVisibleAnymore() {
        let beer0 = makeBeer(imageURL: URL(string: "https://a-url.com")!)
        let beer1 = makeBeer(imageURL: URL(string: "https://any-url.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeBeerListLoading(with: [beer0, beer1])
        XCTAssertEqual(loader.cancelledImageURLs, [], "Expected no cancelled image URL requests until image is not visible")
        
        sut.simulateBeerCellNotVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [beer0.imageURL], "Expected one cancelled image URL request once first image is not visible anymore")
        
        sut.simulateBeerCellNotVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [beer0.imageURL, beer1.imageURL], "Expected two cancelled image URL requests once second image is also not visible anymore")
    }
    
    func test_beerCellLoadingIndicator_isVisibleWhileLoadingImage() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeBeerListLoading(with: [makeBeer(), makeBeer()])
        
        let view0 = sut.simulateBeerCellVisible(at: 0)
        let view1 = sut.simulateBeerCellVisible(at: 1)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, true, "Expected loading indicator for first view while loading first image")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true, "Expected loading indicator for second view while loading second image")
        
        loader.completeImageLoading(at: 0)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expected no loading indicator for first view once first image loading completes successfully")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true, "Expected no loading indicator state change for second view once first image loading completes successfully")
        
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expected no loading indicator state change for first view once second image loading completes with error")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, false, "Expected no loading indicator for second view once second image loading completes with error")
    }
    
    func test_beerCell_rendersImageLoadedFromURL() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeBeerListLoading(with: [makeBeer(), makeBeer()])
        
        let view0 = sut.simulateBeerCellVisible(at: 0)
        let view1 = sut.simulateBeerCellVisible(at: 1)
        XCTAssertEqual(view0?.renderedImage, .none, "Expected no image for first view while loading first image")
        XCTAssertEqual(view1?.renderedImage, .none, "Expected no image for second view while loading second image")
        
        let imageData0 = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(with: imageData0, at: 0)
        XCTAssertEqual(view0?.renderedImage, imageData0, "Expected image for first view once first image loading completes successfully")
        XCTAssertEqual(view1?.renderedImage, .none, "Expected no image state change for second view once first image loading completes successfully")
        
        let imageData1 = UIImage.make(withColor: .blue).pngData()!
        loader.completeImageLoading(with: imageData1, at: 1)
        XCTAssertEqual(view0?.renderedImage, imageData0, "Expected no image state change for first view once second image loading completes successfully")
        XCTAssertEqual(view1?.renderedImage, imageData1, "Expected image for second view once second image loading completes successfully")
    }
    
    func test_beerCellRetryButton_isVisibleOnImageURLLoadError() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeBeerListLoading(with: [makeBeer(), makeBeer()])
        
        let view0 = sut.simulateBeerCellVisible(at: 0)
        let view1 = sut.simulateBeerCellVisible(at: 1)
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action for first view while loading first image")
        XCTAssertEqual(view1?.isShowingRetryAction, false, "Expected no retry action for second view while loading second image")
        
        let imageData = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(with: imageData, at: 0)
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action for first view once first image loading completes successfully")
        XCTAssertEqual(view1?.isShowingRetryAction, false, "Expected no retry action state change for second view once first image loading completes successfully")
        
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action state change for first view once second image loading completes with error")
        XCTAssertEqual(view1?.isShowingRetryAction, true, "Expected retry action for second view once second image loading completes with error")
    }
    
    func test_beerCellRetryButton_isVisibleOnInvalidImageData() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeBeerListLoading(with: [makeBeer()])
        
        let view = sut.simulateBeerCellVisible(at: 0)
        XCTAssertEqual(view?.isShowingRetryAction, false, "Expected no retry action while loading image")
        
        let invalidImageData = Data("invalid image data".utf8)
        loader.completeImageLoading(with: invalidImageData, at: 0)
        XCTAssertEqual(view?.isShowingRetryAction, true, "Expected retry action once image loading completes with invalid image data")
    }
    
    func test_beerCellRetryAction_retriesImageLoad() {
        let beer0 = makeBeer(imageURL: URL(string: "http://url-0.com")!)
        let beer1 = makeBeer(imageURL: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeBeerListLoading(with: [beer0, beer1])
        
        let view0 = sut.simulateBeerCellVisible(at: 0)
        let view1 = sut.simulateBeerCellVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [beer0.imageURL, beer1.imageURL], "Expected two image URL request for the two visible views")
        
        loader.completeImageLoadingWithError(at: 0)
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [beer0.imageURL, beer1.imageURL], "Expected only two image URL requests before retry action")
        
        view0?.simulateRetryAction()
        XCTAssertEqual(loader.loadedImageURLs, [beer0.imageURL, beer1.imageURL, beer0.imageURL], "Expected third imageURL request after first view retry action")
        
        view1?.simulateRetryAction()
        XCTAssertEqual(loader.loadedImageURLs, [beer0.imageURL, beer1.imageURL, beer0.imageURL, beer1.imageURL], "Expected fourth imageURL request after second view retry action")
    }

    func test_beerCell_preloadsImageURLWhenNearVisible() {
        let beer0 = makeBeer(imageURL: URL(string: "http://url-0.com")!)
        let beer1 = makeBeer(imageURL: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeBeerListLoading(with: [beer0, beer1])
        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image URL requests until image is near visible")
        
        sut.simulateBeerCellNearVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [beer0.imageURL], "Expected first image URL request once first image is near visible")
        
        sut.simulateBeerCellNearVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [beer0.imageURL, beer1.imageURL], "Expected second image URL request once second image is near visible")
    }
    
    func test_beerCell_cancelsImageURLPreloadingWhenNotNearVisibleAnymore() {
        let beer0 = makeBeer(imageURL: URL(string: "http://url-0.com")!)
        let beer1 = makeBeer(imageURL: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeBeerListLoading(with: [beer0, beer1])
        XCTAssertEqual(loader.cancelledImageURLs, [], "Expected no cancelled image URL requests until image is not near visible")
        
        sut.simulateBeerCellNotNearVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [beer0.imageURL], "Expected first cancelled image URL request once first image is not near visible anymore")
        
        sut.simulateBeerCellNotNearVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [beer0.imageURL, beer1.imageURL], "Expected second cancelled image URL request once second image is not near visible anymore")
    }
    
    func test_beerCell_doesNotRenderLoadedBeerWhenNotVisibleAnymore() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        loader.completeBeerListLoading(with: [makeBeer()])
        
        let view = sut.simulateBeerCellNotVisible(at: 0)
        loader.completeImageLoading(with: anyImageData())
        
        XCTAssertNil(view?.renderedImage, "Expected no rendered image when an image load finishes after the view is not visible anymore")
    }
    
    func test_loadBeerListCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()

        let exp = expectation(description: "Wait for background queue")
        DispatchQueue.global().async { [weak loader] in
            loader?.completeBeerListLoading()
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_loadImageDataCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeBeerListLoading(with: [makeBeer()])
        _ = sut.simulateBeerCellVisible(at: 0)
        
        let exp = expectation(description: "Wait for background queue")
        DispatchQueue.global().async {
            loader.completeImageLoading(with: anyImageData(), at: 0)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: BeerListViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = BeerListUIComposer.beerListComposedWith(beerListLoader: loader, imageLoader: loader)
        trackForMemoryLeaks(loader)
        trackForMemoryLeaks(sut)
        return (sut, loader)
    }

}
