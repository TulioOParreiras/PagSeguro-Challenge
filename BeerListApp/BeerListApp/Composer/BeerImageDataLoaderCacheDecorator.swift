//
//  BeerImageDataLoaderCacheDecorator.swift
//  BeerListApp
//
//  Created by Tulio Parreiras on 27/01/21.
//

import Foundation
import BeerList

public final class BeerImageDataLoaderCacheDecorator: BeerImageDataLoader {
    private let decoratee: BeerImageDataLoader
    private let cache: BeerImageDataCache

    public init(decoratee: BeerImageDataLoader, cache: BeerImageDataCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    public func loadImageData(from url: URL, completion: @escaping (BeerImageDataLoader.Result) -> Void) -> BeerImageDataLoaderTask {
        return decoratee.loadImageData(from: url) { [weak self] result in
            completion(result.map { data in
                self?.cache.saveIgnoringResult(data, for: url)
                return data
            })
        }
    }
}

private extension BeerImageDataCache {
    func saveIgnoringResult(_ data: Data, for url: URL) {
        save(data, for: url) { _ in }
    }
}
