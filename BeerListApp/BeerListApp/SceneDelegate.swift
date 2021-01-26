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


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        
        let url = URL(string: "https://api.punkapi.com/v2/beers")!
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        let beerListLoader = RemoteBeerListLoader(url: url, client: client)
        let imageLoader = RemoteBeerImageDataLoader(client: client)
        
        let beerListController = BeerListUIComposer.beerListComposedWith(
            beerListLoader: beerListLoader,
            imageLoader: imageLoader)
        
        self.window?.rootViewController = beerListController
    }


}

