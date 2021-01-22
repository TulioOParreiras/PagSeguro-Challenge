//
//  RemoteBeerListLoaderTests.swift
//  BeerListTests
//
//  Created by Tulio Parreiras on 21/01/21.
//

import XCTest

final class RemoteBeerListLoader {
    
}

class HTTPClient {
    var requestedURL: URL?
}

class RemoteBeerListLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClient()
        _ = RemoteBeerListLoader()
        
        XCTAssertNil(client.requestedURL)
    }

}
