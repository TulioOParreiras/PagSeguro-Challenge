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
    
    private struct BeerItem: Decodable {
        let id: Int
        let name: String
        let tagline: String
        let description: String
        let image_url: URL
        let abv: Double
        let ibu: Double
    }
    
    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    func load(completion: @escaping (Swift.Result<[Beer], Error>) -> Void) {
        self.client.get(from: self.url, completion: { [weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success((data, response)):
                do {
                    let item = try JSONDecoder().decode([BeerItem].self, from: data)
                    let beers = item.compactMap { Beer(id: $0.id, name: $0.name, tagline: $0.tagline, description: $0.description, imageURL: $0.image_url, abv: $0.abv, ibu: $0.ibu)}
                    completion(.success(beers))
                } catch {
                    completion(.failure(Error.invalidData))
                }
            case .failure:
                completion(.failure(Error.invalidData))
            }
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
    
    func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
        let response = HTTPURLResponse(
            url: requestedURLs[index],
            statusCode: code,
            httpVersion: nil,
            headerFields: nil
        )!
        messages[index].completion(.success((data, response)))
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
        let invalidData = Data("invalid json".utf8)
        client.complete(withStatusCode: 200, data: invalidData)
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_requestLogin_deliversItemOn200HTTPResponseWithJSONItem() {
        let (sut, client) = makeSUT()
        
        let exp = expectation(description: "Wait for request completion")
        
        let item = Beer(id: 0, name: "a name", tagline: "a tagline", description: "a description", imageURL: URL(string: "https://a-image-url.com")!, abv: 0, ibu: 0)
        
        sut.load { receivedResult in
            switch receivedResult {
            case let .success(receivedItem):
                XCTAssertEqual(receivedItem, [item])
            case let .failure(receivedError):
                XCTFail("Expected success, got \(receivedError) instead")
            }
            exp.fulfill()
        }
        let json: [String: Any] = [
            "id": item.id,
            "name": item.name,
            "tagline": item.tagline,
            "description": item.description,
            "image_url": item.imageURL.absoluteString,
            "abv": item.abv,
            "ibu": item.ibu
        ]
        let data = try! JSONSerialization.data(withJSONObject: [json])
        client.complete(withStatusCode: 200, data: data)
        
//        let data = try! JSONSerialization.data(withJSONObject: [json])
//        client.complete(withStatusCode: 200, data: data)
        
        wait(for: [exp], timeout: 5.0)
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
