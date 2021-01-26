//
//  MainQueueDispatchDecorator.swift
//  BeerListiOS
//
//  Created by Tulio Parreiras on 25/01/21.
//

import Foundation
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

extension MainQueueDispatchDecorator: BeerListLoader where T == BeerListLoader {
    func load(completion: @escaping (BeerListLoader.LoadResult) -> Void) {
        decoratee.load { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: BeerImageDataLoader where T == BeerImageDataLoader {
    func loadImageData(from url: URL, completion: @escaping (BeerImageDataLoader.Result) -> Void) -> BeerImageDataLoaderTask {
        decoratee.loadImageData(from: url) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}
