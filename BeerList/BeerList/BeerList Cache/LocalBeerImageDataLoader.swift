//
//  LocalBeerImageDataLoader.swift
//  BeerList
//
//  Created by Tulio Parreiras on 27/01/21.
//

import Foundation

public protocol BeerImageDataCache {
    typealias Result = Swift.Result<Void, Error>

    func save(_ data: Data, for url: URL, completion: @escaping (Result) -> Void)
}

public final class LocalBeerImageDataLoader {
    private let store: BeerImageDataStore
    
    public init(store: BeerImageDataStore) {
        self.store = store
    }
}

extension LocalBeerImageDataLoader: BeerImageDataCache {
    public typealias SaveResult = BeerImageDataCache.Result

    public enum SaveError: Error {
        case failed
    }

    public func save(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void) {
        store.insert(data, for: url) { [weak self] result in
            guard self != nil else { return }
            completion(result.mapError { _ in SaveError.failed })
        }
    }
}

extension LocalBeerImageDataLoader: BeerImageDataLoader {
    public typealias LoadResult = BeerImageDataLoader.Result

    public enum LoadError: Error {
        case failed
        case notFound
    }
    
    private final class LoadImageDataTask: BeerImageDataLoaderTask {
        private var completion: ((BeerImageDataLoader.Result) -> Void)?
        
        init(_ completion: @escaping (BeerImageDataLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func complete(with result: BeerImageDataLoader.Result) {
            completion?(result)
        }
        
        func cancel() {
            preventFurtherCompletions()
        }
        
        private func preventFurtherCompletions() {
            completion = nil
        }
    }
    
    public func loadImageData(from url: URL, completion: @escaping (BeerImageDataLoader.Result) -> Void) -> BeerImageDataLoaderTask {
        let task = LoadImageDataTask(completion)
        store.retrieve(dataForURL: url) { [weak self] result in
            guard self != nil else { return }
            task.complete(with: result
                            .mapError { _ in LoadError.failed }
                            .flatMap { data in
                                data.map { .success($0) } ?? .failure(LoadError.notFound)
                            })
        }
        return task
    }
}
