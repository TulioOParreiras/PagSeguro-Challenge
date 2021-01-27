//
//  InMemoryBeerStore.swift
//  BeerListAppTests
//
//  Created by Tulio Parreiras on 27/01/21.
//

import Foundation
import BeerList

class InMemoryBeerStore {
    private var BeerImageDataCache: [URL: Data] = [:]
    
}

extension InMemoryBeerStore: BeerImageDataStore {
    func insert(_ data: Data, for url: URL, completion: @escaping (BeerImageDataStore.InsertionResult) -> Void) {
        BeerImageDataCache[url] = data
        completion(.success(()))
    }
    
    func retrieve(dataForURL url: URL, completion: @escaping (BeerImageDataStore.RetrievalResult) -> Void) {
        completion(.success(BeerImageDataCache[url]))
    }
}

extension InMemoryBeerStore {
    static var empty: InMemoryBeerStore {
        InMemoryBeerStore()
    }
}
