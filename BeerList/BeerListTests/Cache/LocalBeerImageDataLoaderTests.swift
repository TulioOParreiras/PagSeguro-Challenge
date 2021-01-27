//
//  LocalBeerImageDataLoaderTests.swift
//  BeerListTests
//
//  Created by Tulio Parreiras on 27/01/21.
//

import XCTest
import BeerList

protocol BeerImageDataStore {
    func retrieve(dataForURL url: URL)
}

final class LocalBeerImageDataLoader {
    private struct Task: BeerImageDataLoaderTask {
        func cancel() {}
    }
    
    private let store: BeerImageDataStore
    
    init(store: BeerImageDataStore) {
        self.store = store
    }
    
    func loadImageData(from url: URL, completion: @escaping (BeerImageDataLoader.Result) -> Void) -> BeerImageDataLoaderTask {
        store.retrieve(dataForURL: url)
        return Task()
    }
}

class LocalBeerImageDataLoaderTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    func test_loadImageDataFromURL_requestsStoredDataForURL() {
        let (sut, store) = makeSUT()
        let url = anyURL()
        
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.retrieve(dataFor: url)])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalBeerImageDataLoader, store: StoreSpy) {
        let store = StoreSpy()
        let sut = LocalBeerImageDataLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private class StoreSpy: BeerImageDataStore {
        enum Message: Equatable {
            case retrieve(dataFor: URL)
        }
        
        private(set) var receivedMessages = [Message]()
        
        func retrieve(dataForURL url: URL) {
            receivedMessages.append(.retrieve(dataFor: url))
        }
    }


}
