//
//  SceneDelegate.swift
//  BeerListApp
//
//  Created by Tulio Parreiras on 26/01/21.
//

import UIKit
import BeerList
import BeerListiOS

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    private lazy var httpClient: HTTPClient = {
        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }()
    
    convenience init(httpClient: HTTPClient) {
        self.init()
        self.httpClient = httpClient
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        configureWindow()
    }
    
    func configureWindow() {
        let url = URL(string: "https://api.punkapi.com/v2/beers")!
        let beerListLoader = RemoteBeerListLoader(url: url, client: httpClient)
        let imageLoader = RemoteBeerImageDataLoader(client: httpClient)
        
        let beerListController = BeerListUIComposer.beerListComposedWith(
            beerListLoader: beerListLoader,
            imageLoader: imageLoader)
        
        self.window?.rootViewController = UINavigationController(rootViewController: beerListController)
        self.window?.makeKeyAndVisible()
    }


}

