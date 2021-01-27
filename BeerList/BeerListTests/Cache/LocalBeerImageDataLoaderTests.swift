//
//  LocalBeerImageDataLoaderTests.swift
//  BeerListTests
//
//  Created by Tulio Parreiras on 27/01/21.
//

import XCTest
import BeerList

protocol BeerImageDataStore {
    typealias Result = Swift.Result<Data?, Error>

    func retrieve(dataForURL url: URL, completion: @escaping (Result) -> Void)
}

final class LocalBeerImageDataLoader {
    private struct Task: BeerImageDataLoaderTask {
        func cancel() {}
    }
    
    public enum Error: Swift.Error {
        case failed
        case notFound
    }
    
    private let store: BeerImageDataStore
    
    init(store: BeerImageDataStore) {
        self.store = store
    }
    
    func loadImageData(from url: URL, completion: @escaping (BeerImageDataLoader.Result) -> Void) -> BeerImageDataLoaderTask {
        store.retrieve(dataForURL: url) { result in
            completion(result
                .mapError { _ in Error.failed }
                .flatMap { data in data.map { .success($0) } ?? .failure(Error.notFound) })
        }
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
    
    func test_loadImageDataFromURL_failsOnStoreError() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: failed(), when: {
            let retrievalError = anyNSError()
            store.complete(with: retrievalError)
        })
    }

    func test_loadImageDataFromURL_deliversNotFoundErrorOnNotFound() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: notFound(), when: {
            store.complete(with: .none)
        })
    }
    
    func test_loadImageDataFromURL_deliversStoredDataOnFoundData() {
        let (sut, store) = makeSUT()
        let foundData = anyData()
        
        expect(sut, toCompleteWith: .success(foundData), when: {
            store.complete(with: foundData)
        })
    }

    // MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalBeerImageDataLoader, store: StoreSpy) {
        let store = StoreSpy()
        let sut = LocalBeerImageDataLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func failed() -> BeerImageDataLoader.Result {
        return .failure(LocalBeerImageDataLoader.Error.failed)
    }
    
    private func notFound() -> BeerImageDataLoader.Result {
        return .failure(LocalBeerImageDataLoader.Error.notFound)
    }

    private func expect(_ sut: LocalBeerImageDataLoader, toCompleteWith expectedResult: BeerImageDataLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        
        _ = sut.loadImageData(from: anyURL()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
                
            case (.failure(let receivedError as LocalBeerImageDataLoader.Error),
                  .failure(let expectedError as LocalBeerImageDataLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
    }
    
    private class StoreSpy: BeerImageDataStore {
        enum Message: Equatable {
            case retrieve(dataFor: URL)
        }
        private var completions = [(BeerImageDataStore.Result) -> Void]()
        private(set) var receivedMessages = [Message]()
        
        func retrieve(dataForURL url: URL, completion: @escaping (BeerImageDataStore.Result) -> Void) {
            receivedMessages.append(.retrieve(dataFor: url))
            completions.append(completion)
        }
        
        func complete(with error: Error, at index: Int = 0) {
            completions[index](.failure(error))
        }
        
        func complete(with data: Data?, at index: Int = 0) {
            completions[index](.success(data))
        }
    }


}
