//
//  RemoteBeerListLoaderTests.swift
//  BeerListTests
//
//  Created by Tulio Parreiras on 21/01/21.
//

import XCTest
import BeerList

class RemoteBeerListLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_requestLoad_requestDataFromURL() {
        let url = URL(string: "https://a-url.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_requestLoadTwice_requestDataFromURLTwice() {
        let url = URL(string: "https://a-url.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_requestLoad_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut: sut, toCompleteWith: .failure(RemoteBeerListLoader.Error.invalidData)) {
            let error = NSError(domain: "Any error", code: 0)
            client.complete(with: error)
        }
    }
    
    func test_requestLoad_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let item = [self.makeBeerItem()]
        let data = self.makeBeerData(item)
        
        let samples = [199, 300, 400, 500]
        samples.enumerated().forEach { index, code in
            self.expect(sut: sut, toCompleteWith: .failure(RemoteBeerListLoader.Error.invalidData)) {
                client.complete(withStatusCode: code, data: data, at: index)
            }
        }
    }
    
    func test_requestLoad_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        self.expect(sut: sut, toCompleteWith: .failure(RemoteBeerListLoader.Error.invalidData)) {
            let invalidData = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidData)
        }
    }
    
    func test_requestLoad_deliversItemOn200HTTPResponseWithJSONItem() {
        let (sut, client) = makeSUT()
        
        let item = [self.makeBeerItem()]
        
        self.expect(sut: sut, toCompleteWith: .success(item)) {
            let data = self.makeBeerData(item)
            client.complete(withStatusCode: 200, data: data)
        }
    }
    
    func test_requestLoad_deliversNoResultWhenSUTInstanceHasBeenDeallocated() {
        let url = URL(string: "http://-a-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteBeerListLoader? = RemoteBeerListLoader(url: url, client: client)
        
        var capturedResults = [RemoteBeerListLoader.Result]()
        sut?.load(completion: { capturedResults.append($0) })
        
        sut = nil
        
        let item = [self.makeBeerItem()]
        let data = self.makeBeerData(item)
        client.complete(withStatusCode: 200, data: data)
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://any-url.com")!, file: StaticString = #file, line: UInt = #line) -> (sut: RemoteBeerListLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteBeerListLoader(url: url, client: client)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, client)
    }
    
    func expect(sut: RemoteBeerListLoader, toCompleteWith expectedResult: RemoteBeerListLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for request completion")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItem), .success(expectedItem)):
                XCTAssertEqual(receivedItem, expectedItem, file: file, line: line)
            case let (.failure(receivedError as RemoteBeerListLoader.Error), .failure(expectedError as RemoteBeerListLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected to receive \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
    }
    
    func makeBeerItem() -> Beer {
        return Beer(id: 0,
                    name: "a name",
                    tagline: "a tagline",
                    description: "a description",
                    imageURL: URL(string: "https://a-image-url.com")!,
                    abv: 0,
                    ibu: 0)
    }
    
    func makeBeerJSON(_ item: Beer) -> [String: Any?] {
        return [
            "id": item.id,
            "name": item.name,
            "tagline": item.tagline,
            "description": item.description,
            "image_url": item.imageURL.absoluteString,
            "abv": item.abv,
            "ibu": item.ibu
        ]
    }
    
    func makeBeerData(_ item: [Beer]) -> Data {
        let json = item.map { self.makeBeerJSON($0) }
        return try! JSONSerialization.data(withJSONObject: json)
    }

}
