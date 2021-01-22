//
//  RemoteBeerListLoader.swift
//  BeerList
//
//  Created by Tulio Parreiras on 22/01/21.
//

import Foundation

public final class RemoteBeerListLoader {
    private let url: URL
    private let client: HTTPClient
    
    public typealias Result = Swift.Result<[Beer], Error>
    
    public enum Error: Swift.Error {
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
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Result) -> Void) {
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
