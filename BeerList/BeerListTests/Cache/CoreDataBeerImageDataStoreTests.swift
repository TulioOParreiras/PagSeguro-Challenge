//
//  CoreDataBeerImageDataStoreTests.swift
//  BeerListTests
//
//  Created by Tulio Parreiras on 27/01/21.
//

import XCTest
import BeerList

extension CoreDataBeerStore: BeerImageDataStore {
    
    public func insert(_ data: Data, for url: URL, completion: @escaping (BeerImageDataStore.InsertionResult) -> Void) {
        
    }
    
    public func retrieve(dataForURL url: URL, completion: @escaping (BeerImageDataStore.RetrievalResult) -> Void) {
        completion(.success(.none))
    }
    
}

class CoreDataBeerImageDataStoreTests: XCTestCase {
    
    func test_retrieveImageData_deliversNotFoundWhenEmpty() {
        let sut = makeSUT()
        
        expect(sut, toCompleteRetrievalWith: notFound(), for: anyURL())
    }
    
    // - MARK: Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> CoreDataBeerStore {
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataBeerStore(storeURL: storeURL)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func notFound() -> BeerImageDataStore.RetrievalResult {
        return .success(.none)
    }

    private func expect(_ sut: CoreDataBeerStore, toCompleteRetrievalWith expectedResult: BeerImageDataStore.RetrievalResult, for url: URL,  file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        sut.retrieve(dataForURL: url) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success( receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
                
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

}
