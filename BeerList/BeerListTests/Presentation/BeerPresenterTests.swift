//
//  BeerPresenterTests.swift
//  BeerListTests
//
//  Created by Tulio Parreiras on 26/01/21.
//

import XCTest
import BeerList

struct BeerViewModel {
    let name: String
    let ibuValue: Double?
    let image: Any?
    let isLoading: Bool
    let shouldRetry: Bool
    
    var ibu: String?  {
        guard let ibu = ibuValue else { return nil }
        return String(describing: ibu)
    }
    
    var hasIbu: Bool {
        return ibuValue != nil
    }
}

protocol BeerView {
    func display(_ model: BeerViewModel)
}


class BeerPresenter {
    private let view: BeerView
    private let imageTransformer: (Data) -> Any?

    init(view: BeerView, imageTransformer: @escaping(Data) -> Any?) {
        self.view = view
        self.imageTransformer = imageTransformer
    }
    
    func didStartLoadingImageData(for model: Beer) {
        view.display(BeerViewModel(
                        name: model.name,
                        ibuValue: model.ibu,
                        image: nil,
                        isLoading: true,
                        shouldRetry: false))
    }
    
    func didFinishLoadingImageData(with data: Data, for model: Beer) {
        view.display(BeerViewModel(
                        name: model.name,
                        ibuValue: model.ibu,
                        image: imageTransformer(data),
                        isLoading: true,
                        shouldRetry: true))
    }
}

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
        XCTAssertEqual(message?.ibuValue, beer.ibu)
        XCTAssertEqual(message?.isLoading, true)
        XCTAssertEqual(message?.shouldRetry, false)
        XCTAssertNil(message?.image)
    }
    
    func test_didFinishLoadingImageData_displaysRetryOnFailedImageTransformation() {
        let (sut, view) = makeSUT(imageTransformer: { _ in nil })
        let beer = makeBeer()
        let data = Data()
        
        sut.didFinishLoadingImageData(with: data, for: beer)
        
        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.name, beer.name)
        XCTAssertEqual(message?.ibuValue, beer.ibu)
        XCTAssertEqual(message?.isLoading, true)
        XCTAssertEqual(message?.shouldRetry, true)
        XCTAssertNil(message?.image)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        imageTransformer: @escaping (Data) -> Any? = { _ in nil },
        file: StaticString = #file,
        line: UInt = #line) -> (sut: BeerPresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = BeerPresenter(view: view, imageTransformer: imageTransformer)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }
    
    func makeBeer(name: String = "A name", imageURL: URL = URL(string: "https://a-url.com")!, ibu: Double? = nil) -> Beer {
        return Beer(id: Int.random(in: 0...100), name: name, tagline: "a tagline", description: "a description", imageURL: imageURL, abv: Double.random(in: 1...10), ibu: ibu)
    }
    
    private class ViewSpy: BeerView {
        var messages = [BeerViewModel]()
        
        func display(_ model: BeerViewModel) {
            messages.append(model)
        }
    }

}
