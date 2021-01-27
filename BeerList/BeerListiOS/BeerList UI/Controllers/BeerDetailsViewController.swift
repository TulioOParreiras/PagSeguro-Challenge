//
//  BeerDetailsViewController.swift
//  BeerListiOS
//
//  Created by Tulio Parreiras on 26/01/21.
//

import UIKit
import BeerList

final class MainQueueDispatchDecorator<T> {
    private let decoratee: T
    
    init(decoratee: T) {
        self.decoratee = decoratee
    }
    
    func dispatch(completion: @escaping () -> Void) {
        guard Thread.isMainThread else {
            return DispatchQueue.main.async(execute: completion)
        }
        
        completion()
    }
}

extension MainQueueDispatchDecorator: BeerImageDataLoader where T == BeerImageDataLoader {
    func loadImageData(from url: URL, completion: @escaping (BeerImageDataLoader.Result) -> Void) -> BeerImageDataLoaderTask {
        decoratee.loadImageData(from: url) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?
    
    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: BeerDetailsView where T: BeerDetailsView, T.Image == UIImage {
    func display(_ model: BeerDetailsViewModel<UIImage>) {
        object?.display(model)
    }
}

public final class BeerDetailsUIComposer {
    private init() { }

    public static func beerDetailsComposedWith(beer: Beer, imageLoader: BeerImageDataLoader) -> BeerDetailsViewController {
        let loader = MainQueueDispatchDecorator(decoratee: imageLoader)
        let presentationAdapter = BeerDetailsImageLoaderPresentationAdapter<WeakRefVirtualProxy<BeerDetailsViewController>, UIImage>(beer: beer, imageLoader: loader)

        let beerDetailsController = BeerDetailsViewController(delegate: presentationAdapter)
        presentationAdapter.presenter = BeerDetailsPresenter(view: WeakRefVirtualProxy(beerDetailsController), imageTransformer: UIImage.init)
        
        return beerDetailsController
    }
}

final class BeerDetailsImageLoaderPresentationAdapter<View: BeerDetailsView, Image>: BeerDetailsViewControllerDelegate where View.Image == Image {
    private let imageLoader: BeerImageDataLoader
    private let beer: Beer
    var presenter: BeerDetailsPresenter<View, Image>?
    
    init(beer: Beer, imageLoader: BeerImageDataLoader) {
        self.beer = beer
        self.imageLoader = imageLoader
    }
    
    func didRequestBeerImageLoad() {
        let model = beer
        presenter?.didStartLoadingImageData(for: model)
        _ = imageLoader.loadImageData(from: beer.imageURL) { [weak self] result in
            switch result {
            case let .success(data):
                self?.presenter?.didFinishLoadingImageData(with: data, for: model)
            case let .failure(error):
                self?.presenter?.didFinishLoadingImageData(with: error, for: model)
            }
        }
    }
}


public protocol BeerDetailsViewControllerDelegate {
    func didRequestBeerImageLoad()
}

public protocol BeerDetailsView {
    associatedtype Image
    
    func display(_ model: BeerDetailsViewModel<Image>)
}

public struct BeerDetailsViewModel<Image> {
    public let name: String
    public let description: String
    public let ibuValue: Double?
    public let abvValue: Double
    public let tagline: String
    public let image: Image?
    public let isLoading: Bool
    public let shouldRetry: Bool
    
    public var ibu: String?  {
        guard let ibu = ibuValue else { return nil }
        return "IBU: " + String(describing: ibu)
    }
    
    public var abv: String {
        return "ABV: " + String(describing: abvValue)
    }
    
    public var hasIbu: Bool {
        return ibuValue != nil
    }
}

public final class BeerDetailsPresenter<View: BeerDetailsView, Image> where View.Image == Image {
    private let view: View
    private let imageTransformer: (Data) -> Image?

    public init(view: View, imageTransformer: @escaping(Data) -> Image?) {
        self.view = view
        self.imageTransformer = imageTransformer
    }
    
    public func didStartLoadingImageData(for model: Beer) {
        view.display(BeerDetailsViewModel(
            name: model.name,
            description: model.description,
            ibuValue: model.ibu,
            abvValue: model.abv,
            tagline: model.tagline,
            image: nil,
            isLoading: true,
            shouldRetry: false
        ))
    }
    
    public func didFinishLoadingImageData(with data: Data, for model: Beer) {
        let image = imageTransformer(data)
        view.display(BeerDetailsViewModel(
            name: model.name,
            description: model.description,
            ibuValue: model.ibu,
            abvValue: model.abv,
            tagline: model.tagline,
            image: image,
            isLoading: false,
            shouldRetry: image == nil
        ))
    }
    
    public func didFinishLoadingImageData(with error: Error, for model: Beer) {
        view.display(BeerDetailsViewModel(
            name: model.name,
            description: model.description,
            ibuValue: model.ibu,
            abvValue: model.abv,
            tagline: model.tagline,
            image: nil,
            isLoading: false,
            shouldRetry: true
        ))
    }
}

public final class BeerDetailsViewController: UIViewController, BeerDetailsView {
    public let imageContainer = UIView()
    public let imageView = UIImageView()
    public let taglineLabel = UILabel()
    public let abvLabel = UILabel()
    public let ibuLabel = UILabel()
    public let descriptionLabel = UILabel()
    
    private(set) public lazy var retryButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private var delegate: BeerDetailsViewControllerDelegate?
    
    public convenience init(delegate: BeerDetailsViewControllerDelegate) {
        self.init()
        self.delegate = delegate
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        loadImage()
    }
    
    public func display(_ model: BeerDetailsViewModel<UIImage>) {
        self.title = model.name
        self.taglineLabel.text = model.tagline
        self.abvLabel.text = model.abv
        self.ibuLabel.text = model.ibu
        self.descriptionLabel.text = model.description
        self.ibuLabel.isHidden = model.ibu == nil
        self.retryButton.isHidden = !model.shouldRetry
        self.imageView.setImageAnimated(model.image)
        self.imageContainer.isShimmering = model.isLoading
    }
    
    func loadImage() {
        delegate?.didRequestBeerImageLoad()
    }
    
    @objc func retryButtonTapped() {
        loadImage()
    }
}
