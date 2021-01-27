//
//  SceneDelegate.swift
//  BeerListApp
//
//  Created by Tulio Parreiras on 26/01/21.
//

import UIKit
import CoreData
import BeerList

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    private lazy var httpClient: HTTPClient = {
        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }()
    
    private lazy var store: BeerImageDataStore = {
        try! CoreDataBeerStore(
            storeURL: NSPersistentContainer
                .defaultDirectoryURL()
                .appendingPathComponent("Beer-store.sqlite"))
    }()
    
    private lazy var baseURL = URL(string: "https://api.punkapi.com/v2/beers")!
    
    private lazy var navigationController = UINavigationController(
        rootViewController: BeerListUIComposer.beerListComposedWith(
            beerListLoader: makeRemoteBeerListLoader(),
            imageLoader: makeRemoteImageLoader(),
            selection: showDetails))
    
    convenience init(httpClient: HTTPClient, store: BeerImageDataStore) {
        self.init()
        self.httpClient = httpClient
        self.store = store
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        configureWindow()
    }
    
    func configureWindow() {
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
    }
    
    private func showDetails(for beer: Beer) {
        let details = BeerDetailsUIComposer.beerDetailsComposedWith(beer: beer, imageLoader: makeRemoteImageLoader())
        navigationController.pushViewController(details, animated: true)
    }

    private func makeRemoteBeerListLoader() -> BeerListLoader {
        let beerListLoader = RemoteBeerListLoader(url: baseURL, client: httpClient)
        return beerListLoader
    }
    
    private func makeRemoteImageLoader() -> BeerImageDataLoader {
        let remoteImageLoader = RemoteBeerImageDataLoader(client: httpClient)
        let localImageLoader = LocalBeerImageDataLoader(store: store)
        let imageLoader = BeerImageDataLoaderWithFallbackComposite(
            primary: localImageLoader,
            fallback: BeerImageDataLoaderCacheDecorator(
                decoratee: remoteImageLoader,
                cache: localImageLoader))
        return imageLoader
    }

}

