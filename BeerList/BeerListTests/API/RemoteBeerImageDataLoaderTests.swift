//
//  RemoteBeerImageDataLoaderTests.swift
//  BeerListTests
//
//  Created by Tulio Parreiras on 26/01/21.
//

import XCTest
import BeerList

func anyURL() -> URL {
    return URL(string: "https://any-url.com")!
}

class RemoteBeerImageDataLoader {
    init(client: Any) {
        
    }
}

class RemoteBeerImageDataLoaderTests: XCTestCase {

    func test_init_doesNotPerformAnyURLRequest() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    private func makeSUT(url: URL = anyURL(), file: StaticString = #file, line: UInt = #line) -> (sut: RemoteBeerImageDataLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteBeerImageDataLoader(client: client)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
    }

    private class HTTPClientSpy {
        var requestedURLs = [URL]()
    }

}
