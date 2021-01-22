//
//  RemoteBeerListLoaderTests.swift
//  BeerListTests
//
//  Created by Tulio Parreiras on 21/01/21.
//

import XCTest
@testable import BeerList

final class RemoteBeerListLoader {
    private let url: URL
    private let client: HTTPClient
    
    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    func load(completion: @escaping (Swift.Result<[Beer], Error>) -> Void) {
        self.client.requestedURL = self.url
    }
}

class HTTPClient {
    var requestedURL: URL?
}

class RemoteBeerListLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClient()
        _ = RemoteBeerListLoader(url: URL(string: "https://any-url.com")!, client: client)
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_requestLoad_requestDataFromURL() {
        let client = HTTPClient()
        let sut = RemoteBeerListLoader(url: URL(string: "https://any-url.com")!, client: client)
        sut.load { _ in }
        
        XCTAssertNotNil(client.requestedURL)
    }

}
