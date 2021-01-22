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
    
    enum Error: Swift.Error {
        case invalidData
    }
    
    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    func load(completion: @escaping (Swift.Result<[Beer], Error>) -> Void) {
        self.client.get(from: self.url, completion: { _ in
            completion(.failure(Error.invalidData))
        })
    }
}

protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    typealias Response = (Result) -> Void
    
    func get(from url: URL, completion: @escaping (Result) -> Void)
}


class HTTPClientSpy: HTTPClient {
    var messages = [(url: URL, completion: HTTPClient.Response)]()
    var requestedURLs: [URL] {
        self.messages.map { $0.url }
    }
    
    typealias Response = HTTPClient.Response
    
    func get(from url: URL, completion: @escaping Response) {
        self.messages.append((url, completion))
    }
    
    func complete(with error: Error, at index: Int = 0) {
        self.messages[index].completion(.failure(error))
    }
    
    func complete(withStatusCode code: Int, data: [String: String] = [:], at index: Int = 0) {
        let response = HTTPURLResponse(
            url: requestedURLs[index],
            statusCode: code,
            httpVersion: nil,
            headerFields: data
        )!
        messages[index].completion(.success((Data(), response)))
    }
}

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
        
        let exp = expectation(description: "Wait for request completion")
        
        sut.load { receivedResult in
            switch receivedResult {
            case let .success(receivedItem):
                XCTFail("Expected failure, got \(receivedItem) instead")
            case let .failure(receivedError):
                XCTAssertEqual(receivedError, RemoteBeerListLoader.Error.invalidData)
            }
            exp.fulfill()
        }
        let error = NSError(domain: "Any error", code: 0)
        client.complete(with: error)
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_requestLoad_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 300, 400, 500]
        samples.enumerated().forEach { index, code in
            let exp = expectation(description: "Wait for request completion")
            
            sut.load { receivedResult in
                switch receivedResult {
                case let .success(receivedItem):
                    XCTFail("Expected failure, got \(receivedItem) instead")
                case let .failure(receivedError):
                    XCTAssertEqual(receivedError, RemoteBeerListLoader.Error.invalidData)
                }
                exp.fulfill()
            }
            client.complete(withStatusCode: code, at: index)
            
            wait(for: [exp], timeout: 1.0)
        }
    }
    
    func test_requestLoad_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        let exp = expectation(description: "Wait for request completion")
        
        sut.load { receivedResult in
            switch receivedResult {
            case let .success(receivedItem):
                XCTFail("Expected failure, got \(receivedItem) instead")
            case let .failure(receivedError):
                XCTAssertEqual(receivedError, RemoteBeerListLoader.Error.invalidData)
            }
            exp.fulfill()
        }
        let invalidJSON = [String: String]()
        client.complete(withStatusCode: 200, data: invalidJSON)
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://any-url.com")!, file: StaticString = #file, line: UInt = #line) -> (sut: RemoteBeerListLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteBeerListLoader(url: url, client: client)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, client)
    }
    
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }

}
