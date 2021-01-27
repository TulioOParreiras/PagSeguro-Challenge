//
//  LocalBeerImageDataLoader.swift
//  BeerList
//
//  Created by Tulio Parreiras on 27/01/21.
//

import Foundation

public final class LocalBeerImageDataLoader {
    private final class Task: BeerImageDataLoaderTask {
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
    
    public enum Error: Swift.Error {
        case failed
        case notFound
    }
    
    private let store: BeerImageDataStore
    
    public init(store: BeerImageDataStore) {
        self.store = store
    }
    
    public func loadImageData(from url: URL, completion: @escaping (BeerImageDataLoader.Result) -> Void) -> BeerImageDataLoaderTask {
        let task = Task(completion)
        store.retrieve(dataForURL: url) { [weak self] result in
            guard self != nil else { return }
            task.complete(with: result
                            .mapError { _ in Error.failed }
                            .flatMap { data in
                                data.map { .success($0) } ?? .failure(Error.notFound)
                            })
        }
        return task
    }
}
