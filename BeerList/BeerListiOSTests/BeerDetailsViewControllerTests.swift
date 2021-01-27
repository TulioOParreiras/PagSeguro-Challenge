//
//  BeerDetailsViewControllerTests.swift
//  BeerListiOSTests
//
//  Created by Tulio Parreiras on 26/01/21.
//

import XCTest
import BeerList

final class BeerDetailsViewController: UIViewController {
    private let imageContainer = UIView()
    
    private var imageLoader: BeerImageDataLoader?
    convenience init(model: Beer, imageLoader: BeerImageDataLoader) {
        self.init()
        self.title = model.name
        self.imageLoader = imageLoader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadImage()
    }
    
    func loadImage() {
        imageContainer.isShimmering = true
        imageLoader?.loadImageData(from: URL(string: "https://a-url.com")!) { _ in
            self.imageContainer.isShimmering = false
        }
    }
}

class BeerDetailsViewControllerTests: XCTestCase {

    func test_beerDetailsView_hasTitle() {
        let model = makeBeer()
        let loader = LoaderSpy()
        let sut = BeerDetailsViewController(model: model, imageLoader: loader)
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.title, model.name)
    }
    
    func test_loadView_doesRequestImageLoad() {
        let model = makeBeer()
        let loader = LoaderSpy()
        let sut = BeerDetailsViewController(model: model, imageLoader: loader)
        XCTAssertEqual(loader.loadImageCallCount, 0)
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadImageCallCount, 1)
    }
    
    func test_loadingBeerImageIndicator_isVisibleWhileLoadingImage() {
        let model = makeBeer()
        let loader = LoaderSpy()
        let sut = BeerDetailsViewController(model: model, imageLoader: loader)
        XCTAssertFalse(sut.isShowingImageLoadingIndicator)
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingImageLoadingIndicator)
        
        loader.completeImageLoading()
        XCTAssertFalse(sut.isShowingImageLoadingIndicator)
    }
    
    func makeBeer(name: String = "A name", imageURL: URL = URL(string: "https://a-url.com")!, ibu: Double? = nil) -> Beer {
        return Beer(id: Int.random(in: 0...100), name: name, tagline: "a tagline", description: "a description", imageURL: imageURL, abv: Double.random(in: 1...10), ibu: ibu)
    }
    
    final class LoaderSpy: BeerImageDataLoader {
        private var loadRequests = [(url: URL, completion: (BeerImageDataLoader.Result) -> Void)]()
        var loadImageCallCount: Int {
            return loadRequests.count
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
    }

}

extension BeerDetailsViewController {
    
    var isShowingImageLoadingIndicator: Bool {
        return imageContainer.isShimmering
    }
    
}
