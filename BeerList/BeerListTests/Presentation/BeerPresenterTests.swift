//
//  BeerPresenterTests.swift
//  BeerListTests
//
//  Created by Tulio Parreiras on 26/01/21.
//

import XCTest
import BeerList

class BeerPresenterTests: XCTestCase {
    
    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    
    func test_didStartLoadingImageData_displaysLoadingImage() {
        let (sut, view) = makeSUT()
        let beer = makeBeer()
        
        sut.didStartLoadingImageData(for: beer)
        
        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.name, beer.name)
        XCTAssertEqual(message?.abvValue, beer.abv)
        XCTAssertEqual(message?.isLoading, true)
        XCTAssertEqual(message?.shouldRetry, false)
        XCTAssertNil(message?.image)
    }
    
    func test_didFinishLoadingImageData_displaysRetryOnFailedImageTransformation() {
        let (sut, view) = makeSUT(imageTransformer: fail)
        let beer = makeBeer()
        let data = Data()
        
        sut.didFinishLoadingImageData(with: data, for: beer)
        
        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.name, beer.name)
        XCTAssertEqual(message?.abvValue, beer.abv)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.shouldRetry, true)
        XCTAssertNil(message?.image)
    }
    
    func test_didFinishLoadingImageData_displaysImageOnSuccessfulTransformation() {
        let beer = makeBeer()
        let data = Data()
        let transformedData = AnyImage()
        let (sut, view) = makeSUT(imageTransformer: { _ in transformedData })
        
        sut.didFinishLoadingImageData(with: data, for: beer)
        
        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.name, beer.name)
        XCTAssertEqual(message?.abvValue, beer.abv)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.shouldRetry, false)
        XCTAssertEqual(message?.image, transformedData)
    }
    
    func test_didFinishLoadingImageDataWithError_displaysRetry() {
        let beer = makeBeer()
        let (sut, view) = makeSUT()
        
        sut.didFinishLoadingImageData(with: anyNSError(), for: beer)
        
        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.name, beer.name)
        XCTAssertEqual(message?.abvValue, beer.abv)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.shouldRetry, true)
        XCTAssertNil(message?.image)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        imageTransformer: @escaping (Data) -> AnyImage? = { _ in nil },
        file: StaticString = #file,
        line: UInt = #line) -> (sut: BeerPresenter<ViewSpy, AnyImage>, view: ViewSpy) {
        let view = ViewSpy()
        let sut = BeerPresenter(view: view, imageTransformer: imageTransformer)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }
    
    func makeBeer(name: String = "A name", imageURL: URL = URL(string: "https://a-url.com")!, ibu: Double? = nil) -> Beer {
        return Beer(id: Int.random(in: 0...100), name: name, tagline: "a tagline", description: "a description", imageURL: imageURL, abv: Double.random(in: 1...10), ibu: ibu)
    }
    
    func anyNSError() -> NSError {
        return NSError(domain: "a error", code: 1)
    }
    
    private var fail: (Data) -> AnyImage? {
        return { _ in nil }
    }
    
    private struct AnyImage: Equatable {}
    
    private class ViewSpy: BeerView {
        var messages = [BeerViewModel<AnyImage>]()
        
        func display(_ model: BeerViewModel<AnyImage>) {
            messages.append(model)
        }
    }

}
