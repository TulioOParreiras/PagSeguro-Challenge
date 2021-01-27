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
    private lazy var retryButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private var imageLoader: BeerImageDataLoader?
    private var model: Beer!
    convenience init(model: Beer, imageLoader: BeerImageDataLoader) {
        self.init()
        self.model = model
        self.imageLoader = imageLoader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = model.name
        loadImage()
    }
    
    func loadImage() {
        retryButton.isHidden = true
        imageContainer.isShimmering = true
        _ = imageLoader?.loadImageData(from: model.imageURL) { result in
            self.imageContainer.isShimmering = false
            if let data = try? result.get(), let image = UIImage(data: data) {
                self.imageView.image = image
            } else {
                self.retryButton.isHidden = false
            }
        }
    }
    
    @objc func retryButtonTapped() {
        loadImage()
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
    
    // MARK: - Helpers
    
    private func makeSUT(with beer: Beer = makeBeer()) -> (sut: BeerDetailsViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = BeerDetailsViewController(model: beer, imageLoader: loader)
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
    
}

extension UIControl {
    
    func simulateEvent(_ event: UIControl.Event) {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: event)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
    
}
