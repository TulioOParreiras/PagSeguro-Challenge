//
//  BeerImageDataLoaderWithFallbackComposite.swift
//  BeerListApp
//
//  Created by Tulio Parreiras on 27/01/21.
//

import Foundation
import BeerList

public class BeerImageDataLoaderWithFallbackComposite: BeerImageDataLoader {
    private let primary: BeerImageDataLoader
    private let fallback: BeerImageDataLoader

    public init(primary: BeerImageDataLoader, fallback: BeerImageDataLoader) {
        self.primary = primary
        self.fallback = fallback
    }
    
    private class TaskWrapper: BeerImageDataLoaderTask {
        var wrapped: BeerImageDataLoaderTask?
        
        func cancel() {
            wrapped?.cancel()
        }
    }

    public func loadImageData(from url: URL, completion: @escaping (BeerImageDataLoader.Result) -> Void) -> BeerImageDataLoaderTask {
        let task = TaskWrapper()
        task.wrapped = primary.loadImageData(from: url) { [weak self] result in
            switch result {
            case .success:
                completion(result)
                
            case .failure:
                task.wrapped = self?.fallback.loadImageData(from: url, completion: completion)
            }

        }
        return task
    }
}
