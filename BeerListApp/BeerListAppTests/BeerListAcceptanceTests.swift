//
//  BeerListAcceptanceTests.swift
//  BeerListAppTests
//
//  Created by Tulio Parreiras on 26/01/21.
//

import XCTest
import BeerList
import BeerListiOS
@testable import BeerListApp


class BeerListAcceptanceTests: XCTestCase {

    func test_onLaunch_displaysRemoteBeerListWhenCustomerHasConnectivity() {
        let beerList = launch(httpClient: .online(response))
        
        XCTAssertEqual(beerList.numberOfRenderedBeerCells(), 2)
        XCTAssertEqual(beerList.renderedBeerImageData(at: 0), makeImageData())
        XCTAssertEqual(beerList.renderedBeerImageData(at: 1), makeImageData())
    }
    
    func test_onLaunch_displaysEmptyBeerListWhenCustomerHasNoConnectivity() {
        let beerList = launch(httpClient: .offline)
        
        XCTAssertEqual(beerList.numberOfRenderedBeerCells(), 0)
    }
    
    // MARK: - Helpers

    private func launch(
        httpClient: HTTPClientStub,
        store: InMemoryBeerStore = .empty
    ) -> BeerListViewController {
        let sut = SceneDelegate(httpClient: httpClient, store: store)
        sut.window = UIWindow()
        sut.configureWindow()
        
        let nav = sut.window?.rootViewController as? UINavigationController
        return nav?.topViewController as! BeerListViewController
    }

    private class HTTPClientStub: HTTPClient {
        private class Task: HTTPClientTask {
            func cancel() {}
        }
        
        private let stub: (URL) -> HTTPClient.Result
                
        init(stub: @escaping (URL) -> HTTPClient.Result) {
            self.stub = stub
        }

        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
            completion(stub(url))
            return Task()
        }
        
        static var offline: HTTPClientStub {
            HTTPClientStub(stub: { _ in .failure(NSError(domain: "offline", code: 0)) })
        }
        static func online(_ stub: @escaping (URL) -> (Data, HTTPURLResponse)) -> HTTPClientStub {
            HTTPClientStub { url in .success(stub(url)) }
        }
    }

    private func response(for url: URL) -> (Data, HTTPURLResponse) {
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (makeData(for: url), response)
    }
    
    private func makeData(for url: URL) -> Data {
        switch url.absoluteString {
        case "http://image.com":
            return makeImageData()
            
        default:
            return makeBeerListData()
        }
    }
    
    private func makeImageData() -> Data {
        return UIImage.make(withColor: .red).pngData()!
    }
    
    private func makeBeerListData() -> Data {
        return try! JSONSerialization.data(withJSONObject: [
            makeBeerJSON(makeBeer(name: "a name", imageURL: URL(string: "http://image.com")!, ibu: 1.5)),
            makeBeerJSON(makeBeer(name: "a name", imageURL: URL(string: "http://image.com")!, ibu: nil))
        ])
    }
    
    func makeBeer(name: String = "A name", imageURL: URL = URL(string: "https://a-url.com")!, ibu: Double? = nil) -> Beer {
        return Beer(id: Int.random(in: 0...100),
                    name: name,
                    tagline: "a tagline",
                    description: "a description",
                    imageURL: imageURL,
                    abv: Double.random(in: 1...10),
                    ibu: ibu)
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

}
