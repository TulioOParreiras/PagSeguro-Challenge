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
    private let imageView = UIImageView()
    private let retryButton = UIButton()
    
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
        retryButton.isHidden = true
        imageContainer.isShimmering = true
        _ = imageLoader?.loadImageData(from: URL(string: "https://a-url.com")!) { result in
            self.imageContainer.isShimmering = false
            switch result {
            case let .success(data):
                self.imageView.image = UIImage(data: data)
            case .failure:
                self.retryButton.isHidden = false
            }
        }
    }
}

func makeBeer(name: String = "A name", imageURL: URL = URL(string: "https://a-url.com")!, ibu: Double? = nil) -> Beer {
    return Beer(id: Int.random(in: 0...100), name: name, tagline: "a tagline", description: "a description", imageURL: imageURL, abv: Double.random(in: 1...10), ibu: ibu)
}

func anyNSError() -> NSError {
    return NSError(domain: "A domain", code: 1)
}

class BeerDetailsViewControllerTests: XCTestCase {

    func test_beerDetailsView_hasTitle() {
        let model = makeBeer()
        let (sut, _) = makeSUT(with: model)
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.title, model.name)
    }
    
    func test_loadView_doesRequestImageLoad() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadImageCallCount, 0)
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadImageCallCount, 1)
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
        
        let imageData = UIImage.make(withColor: .red).pngData()!
        sut.loadViewIfNeeded()
        XCTAssertFalse(sut.isShowingRetryButton)
        loader.completeImageLoadingWithError()
        XCTAssertTrue(sut.isShowingRetryButton)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(with model: Beer = makeBeer()) -> (sut: BeerDetailsViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = BeerDetailsViewController(model: model, imageLoader: loader)
        return (sut, loader)
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
    
}
