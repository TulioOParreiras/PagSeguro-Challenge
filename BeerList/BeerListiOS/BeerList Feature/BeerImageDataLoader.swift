//
//  BeerImageDataLoader.swift
//  BeerListiOS
//
//  Created by Tulio Parreiras on 25/01/21.
//

import Foundation

public protocol BeerImageDataLoaderTask {
    func cancel()
}

public protocol BeerImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    func loadImageData(from url: URL, completion: @escaping(Result) -> Void) -> BeerImageDataLoaderTask
}
