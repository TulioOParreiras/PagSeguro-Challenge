//
//  BeerDetailsUIIntegraationTests.swift
//  BeerListiOSTests
//
//  Created by Tulio Parreiras on 26/01/21.
//

import XCTest
import BeerList
import BeerListiOS
import BeerListApp

class BeerDetailsUIIntegraationTests: XCTestCase {

    func test_beerDetailsView_hasTitle() {
        let beer = makeBeer()
        let (sut, _) = makeSUT(with: beer)
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.title, beer.name)
    }
    
    func test_loadView_doesRequestImageLoad() {
        let beer = makeBeer()
        let (sut, loader) = makeSUT(with: beer)
        XCTAssertEqual(loader.loadedURLs, [])
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadedURLs, [beer.imageURL])
    }
    
    func test_loadingBeerImageIndicator_isVisibleWhileLoadingImage() {
        let (sut, loader) = makeSUT()
        XCTAssertFalse(sut.isShowingImageLoadingIndicator)
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingImageLoadingIndicator)
        
        loader.completeImageLoading()
        XCTAssertFalse(sut.isShowingImageLoadingIndicator)
    }
    
    func test_loadImageCompletion_rendersLoadedImageSuccessfully() {
        let (sut, loader) = makeSUT()
        
        let imageData = UIImage.make(withColor: .red).pngData()!
        sut.loadViewIfNeeded()
        loader.completeImageLoading(with: imageData)
        XCTAssertEqual(sut.renderedImage, imageData)
    }
    
    func test_imageRetryButton_isVisibleOnImageLoadError() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertFalse(sut.isShowingRetryButton)
        loader.completeImageLoadingWithError()
        XCTAssertTrue(sut.isShowingRetryButton)
    }
    
    func test_imageRetryButton_isVisibleOnInvalidImageData() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertFalse(sut.isShowingRetryButton)
        
        let invalidData = Data("invalid data".utf8)
        loader.completeImageLoading(with: invalidData)
        XCTAssertTrue(sut.isShowingRetryButton)
    }
    
    func test_retryAction_retriesImageLoad() {
        let beer = makeBeer()
        let (sut, loader) = makeSUT(with: beer)
        
        XCTAssertEqual(loader.loadedURLs, [])
        sut.loadViewIfNeeded()
        
        loader.completeImageLoadingWithError()
        XCTAssertEqual(loader.loadedURLs, [beer.imageURL])
        
        sut.simulateRetryAction()
        XCTAssertEqual(loader.loadedURLs, [beer.imageURL, beer.imageURL])
    }
    
    func test_beerDetailsView_rendersBeerSuccessfully() {
        let beer = makeBeer()
        let (sut, _) = makeSUT(with: beer)
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.taglineText, beer.tagline)
        XCTAssertEqual(sut.abvText, "ABV: \(beer.abv)")
        XCTAssertEqual(sut.isShowingIbu, beer.ibu != nil)
        XCTAssertEqual(sut.descriptionText, beer.description)
        if let ibu = beer.ibu {
            XCTAssertEqual(sut.ibuText, "IBU: \(ibu)")
        }
    }
    
    // MARK: - Helpers
    
    private func makeSUT(with beer: Beer = makeBeer(), file: StaticString = #file, line: UInt = #line) -> (sut: BeerDetailsViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = BeerDetailsUIComposer.beerDetailsComposedWith(beer: beer, imageLoader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    final class LoaderSpy: BeerImageDataLoader {
        private var loadRequests = [(url: URL, completion: (BeerImageDataLoader.Result) -> Void)]()
        var loadedURLs: [URL] {
            return loadRequests.map { $0.url }
        }
        
        private struct TaskSpy: BeerImageDataLoaderTask {
            func cancel() { }
        }
        
        func loadImageData(from url: URL, completion: @escaping (BeerImageDataLoader.Result) -> Void) -> BeerImageDataLoaderTask {
            loadRequests.append((url, completion))
            return TaskSpy()
        }
        
        func completeImageLoading(with data: Data = Data(), at index: Int = 0) {
            loadRequests[index].completion(.success(data))
        }
        
        func completeImageLoadingWithError(error: NSError = anyNSError(), at index: Int = 0) {
            loadRequests[index].completion(.failure(error))
        }
    }

}

extension BeerDetailsViewController {
    
    var isShowingImageLoadingIndicator: Bool {
        return imageContainer.isShimmering
    }
    
    var renderedImage: Data? {
        return imageView.image?.pngData()
    }
    
    var isShowingRetryButton: Bool {
        return !retryButton.isHidden
    }
    
    func simulateRetryAction() {
        retryButton.simulateEvent(.touchUpInside)
    }
    
    var taglineText: String? {
        return taglineLabel.text
    }
    
    var abvText: String? {
        return abvLabel.text
    }
    
    var isShowingIbu: Bool {
        return !ibuLabel.isHidden
    }
    
    var ibuText: String? {
        return ibuLabel.text
    }
    
    var descriptionText: String? {
        return descriptionLabel.text
    }
    
}
