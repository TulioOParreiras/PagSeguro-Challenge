//
//  BeerListUIComposer.swift
//  BeerListiOS
//
//  Created by Tulio Parreiras on 25/01/21.
//

import UIKit
import BeerList

public final class BeerListUIComposer {
    private init() { }
    
    public static func beerListComposedWith(beerListLoader: BeerListLoader, imageLoader: BeerImageDataLoader) -> BeerListViewController {
        let presentationAdapter = BeerListLoaderPresentationAdapter(beerListLoader: MainQueueDispatchDecorator(decoratee: beerListLoader))
        
        let beerListController = BeerListViewController.makeWith(
            delegate: presentationAdapter,
            title: BeerListPresenter.title)
        
        presentationAdapter.presenter = BeerListPresenter(
            beerListView: BeerListViewAdapter(controller: beerListController, imageLoader: imageLoader), loadingView: WeakRefVirtualProxy(beerListController))
        return beerListController
    }

}

private extension BeerListViewController {
    static func makeWith(delegate: BeerListViewControllerDelegate, title: String) -> BeerListViewController {
        let bundle = Bundle(for: BeerListViewController.self)
        let storyboard = UIStoryboard(name: "BeerList", bundle: bundle)
        let beerListController = storyboard.instantiateInitialViewController() as! BeerListViewController
        beerListController.delegate = delegate
        beerListController.title = title
        return beerListController
    }
}

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

extension MainQueueDispatchDecorator: BeerListLoader where T == BeerListLoader {
    func load(completion: @escaping (BeerListLoader.LoadResult) -> Void) {
        decoratee.load { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

private final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?
    
    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: BeerListLoadingView where T: BeerListLoadingView {
    func display(_ viewModel: BeerListLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: BeerView where T: BeerView, T.Image == UIImage {
    func display(_ model: BeerViewModel<UIImage>) {
        object?.display(model)
    }
}

private final class BeerListViewAdapter: BeerListView {
    private weak var controller: BeerListViewController?
    private let imageLoader: BeerImageDataLoader
    
    init(controller: BeerListViewController, imageLoader: BeerImageDataLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func display(_ viewModel: BeerListViewModel) {
        controller?.tableModel = viewModel.beerList.map { model in
            let adapter = BeerDataLoaderPresentationAdapter<WeakRefVirtualProxy<BeerCellController>, UIImage>(model: model, imageLoader: imageLoader)
            let view = BeerCellController(delegate: adapter)
            
            adapter.presenter = BeerPresenter(
                view: WeakRefVirtualProxy(view),
                imageTransformer: UIImage.init
            )
            return view
        }
    }
}

private final class BeerListLoaderPresentationAdapter: BeerListViewControllerDelegate {
    private let beerListLoader: BeerListLoader
    var presenter: BeerListPresenter?
    
    init(beerListLoader: BeerListLoader) {
        self.beerListLoader = beerListLoader
    }
    
    func didRequestBeerListRefresh() {
        presenter?.didStartLoadingBeerList()
        
        beerListLoader.load { [weak self] result in
            switch result {
            case let .success(beerList):
                self?.presenter?.didFinishLoadingBeerList(with: beerList)
            case let .failure(error):
                self?.presenter?.didFinishLoadingBeerList(with: error)
            }
        }
    }
}

private final class BeerDataLoaderPresentationAdapter<View: BeerView, Image>: BeerCellControllerDelegate where View.Image == Image {
    private let model: Beer
    private let imageLoader: BeerImageDataLoader
    private var task: BeerImageDataLoaderTask?
    
    var presenter: BeerPresenter<View, Image>?
    
    init(model: Beer, imageLoader: BeerImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    func didRequestImage() {
        presenter?.didStartLoadingImageData(for: model)
        
        let model = self.model
        task = imageLoader.loadImageData(from: model.imageURL, completion: { [weak self] result in
            switch result {
            case let .success(data):
                self?.presenter?.didFinishLoadingImageData(with: data, for: model)
                
            case let .failure(error):
                self?.presenter?.didFinishLoadingImageData(with: error, for: model)
            }
        })
    }
    
    func didCancelImageRequest() {
        task?.cancel()
    }
    
}
