//
//  BeerPresenterTests.swift
//  BeerListTests
//
//  Created by Tulio Parreiras on 26/01/21.
//

import XCTest
import BeerList

struct BeerViewModel<Image> {
    let name: String
    let ibuValue: Double?
    let image: Image?
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
    associatedtype Image
    
    func display(_ model: BeerViewModel<Image>)
}


class BeerPresenter<View: BeerView, Image> where View.Image == Image {
    private let view: View
    private let imageTransformer: (Data) -> Image?

    init(view: View, imageTransformer: @escaping(Data) -> Image?) {
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
        let image = imageTransformer(data)
        view.display(BeerViewModel(
                        name: model.name,
                        ibuValue: model.ibu,
                        image: image,
                        isLoading: false,
                        shouldRetry: image == nil))
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
        let (sut, view) = makeSUT(imageTransformer: fail)
        let beer = makeBeer()
        let data = Data()
        
        sut.didFinishLoadingImageData(with: data, for: beer)
        
        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.name, beer.name)
        XCTAssertEqual(message?.ibuValue, beer.ibu)
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
        XCTAssertEqual(message?.ibuValue, beer.ibu)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.shouldRetry, false)
        XCTAssertEqual(message?.image, transformedData)
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
