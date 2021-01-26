//
//  BeerListAPIEndToEndTests.swift
//  BeerListAPIEndToEndTests
//
//  Created by Tulio Parreiras on 24/01/21.
//

import XCTest
import BeerList

class BeerListAPIEndToEndTests: XCTestCase {

    func test_endToEndServerGETBeersResult_returnsNonEmptyResult() {
        let result = getBeersResult()
        switch result {
        case let .success(beers):
            XCTAssertFalse(beers.isEmpty)
        case let .failure(error):
            XCTFail("Expected success, got \(error) instead")
        }
    }
    
    func test_endToEndTestServerGETBeerImageDataResult_matchesFixedTestAccountData() {
        switch getBeerImageDataResult() {
        case let .success(data)?:
            XCTAssertFalse(data.isEmpty, "Expected non-empty image data")
            
        case let .failure(error)?:
            XCTFail("Expected successful image data result, got \(error) instead")
            
        default:
            XCTFail("Expected successful image data result, got no result instead")
        }
    }
    
    // MARK: - Helpers
    
    private func getBeersResult(file: StaticString = #file, line: UInt = #line) -> BeerListLoader.LoadResult {
        let testServerURL = URL(string: "https://api.punkapi.com/v2/beers")!
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        let loader = RemoteBeerListLoader(url: testServerURL, client: client)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        let exp = expectation(description: "Wait for get completion")
        
        var expectedResult: BeerListLoader.LoadResult!
        loader.load { result in
            expectedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
        return expectedResult
    }
    
    private func getBeerImageDataResult(file: StaticString = #file, line: UInt = #line) -> BeerImageDataLoader.Result? {
        let testServerURL = URL(string: "https://images.punkapi.com/v2/keg.png")!
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        let loader = RemoteBeerImageDataLoader(client: client)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        
        let exp = expectation(description: "Wait for load completion")
        
        var receivedResult: BeerImageDataLoader.Result?
        _ = loader.loadImageData(from: testServerURL) { result in
            receivedResult = result
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5.0)
        
        return receivedResult
    }

}
