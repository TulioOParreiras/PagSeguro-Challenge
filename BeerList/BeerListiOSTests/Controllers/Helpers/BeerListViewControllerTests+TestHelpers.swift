//
//  BeerListViewControllerTests+TestHelpers.swift
//  BeerListiOSTests
//
//  Created by Tulio Parreiras on 25/01/21.
//

import UIKit
import BeerList
import BeerListiOS

extension BeerListUIIntegrationsTests {
    
    class LoaderSpy: BeerListLoader, BeerImageDataLoader {
        
        // MARK: - BeerListLoader
        
        private var beerListRequests = [(LoadResponse)]()
        var loadBeerListCallCount: Int {
            return beerListRequests.count
        }
        
        func load(completion: @escaping LoadResponse) {
            beerListRequests.append(completion)
        }
        
        func completeBeerListLoading(with beers: [Beer] = [], at index: Int = 0) {
            beerListRequests[index](.success(beers))
        }
        
        func completeBeerListLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "a domain", code: 1)
            beerListRequests[index](.failure(error))
        }
        
        // MARK: - BeerImageDataLoader
        
        private struct TaskSpy: BeerImageDataLoaderTask {
            let cancelCallback: () -> Void
            func cancel() {
                cancelCallback()
            }
        }
        
        var loadImageRequests = [(url: URL, completion: (BeerImageDataLoader.Result) -> Void)]()
        var loadedImageURLs: [URL] {
            return loadImageRequests.map { $0.url }
        }
        var cancelledImageURLs: [URL] = []
        
        func loadImageData(from url: URL, completion: @escaping(BeerImageDataLoader.Result) -> Void) -> BeerImageDataLoaderTask {
            loadImageRequests.append((url, completion))
            return TaskSpy { [weak self] in self?.cancelledImageURLs.append(url) }
        }
        
        func completeImageLoading(with imageData: Data = Data(), at index: Int = 0) {
            loadImageRequests[index].completion(.success(imageData))
        }
        
        func completeImageLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "a domain", code: 1)
            loadImageRequests[index].completion(.failure(error))
        }
    }
    
}
