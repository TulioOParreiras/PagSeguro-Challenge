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
        let testServerURL = URL(string: "https://api.punkapi.com/v2/beers")!
        let client = URLSessionHTTPClient()
        let loader = RemoteBeerListLoader(url: testServerURL, client: client)
        
        let exp = expectation(description: "Wait for get completion")
        
        loader.load { result in
            switch result {
            case let .success(beers):
                XCTAssertFalse(beers.isEmpty)
            case let .failure(error):
                XCTFail("Expected success, got \(error) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
    }

}
