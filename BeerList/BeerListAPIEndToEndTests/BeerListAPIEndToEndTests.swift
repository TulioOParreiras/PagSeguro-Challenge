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
    
    // MARK: - Helpers
    
    private func getBeersResult(file: StaticString = #file, line: UInt = #line) -> BeerListLoader.LoadResult {
        let testServerURL = URL(string: "https://api.punkapi.com/v2/beers")!
        let client = URLSessionHTTPClient()
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

}
