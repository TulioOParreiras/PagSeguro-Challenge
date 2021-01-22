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
    
    typealias Result = Swift.Result<[Beer], Error>
    
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
    
    func load(completion: @escaping (Result) -> Void) {
        self.client.get(from: self.url, completion: { [weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success((data, response)):
                guard (response as HTTPURLResponse).statusCode == 200 else {
                    return completion(.failure(.invalidData))
                }
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
        
        expect(sut: sut, toCompleteWith: .failure(.invalidData)) {
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
            self.expect(sut: sut, toCompleteWith: .failure(.invalidData)) {
                client.complete(withStatusCode: code, data: data, at: index)
            }
        }
    }
    
    func test_requestLoad_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        self.expect(sut: sut, toCompleteWith: .failure(.invalidData)) {
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
    
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
    
    func expect(sut: RemoteBeerListLoader, toCompleteWith expectedResult: RemoteBeerListLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for request completion")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItem), .success(expectedItem)):
                XCTAssertEqual(receivedItem, expectedItem, file: file, line: line)
            case let (.failure(receivedError), .failure(expectedError)):
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
    
    func makeBeerJSON(_ item: Beer) -> [String: Any] {
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
