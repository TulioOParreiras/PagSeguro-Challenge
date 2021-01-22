//
//  RemoteBeerListLoader.swift
//  BeerList
//
//  Created by Tulio Parreiras on 22/01/21.
//

import Foundation

final class RemoteBeerListMapper {
    
    private struct BeerItem: Decodable {
        let id: Int
        let name: String
        let tagline: String
        let description: String
        let image_url: URL
        let abv: Double
        let ibu: Double
    }
    
    static func map(data: Data, from response: HTTPURLResponse) throws -> [Beer] {
        guard (response as HTTPURLResponse).statusCode == 200 else {
            throw RemoteBeerListLoader.Error.invalidData
        }
        do {
            let item = try JSONDecoder().decode([BeerItem].self, from: data)
            let beers = item.compactMap { Beer(id: $0.id, name: $0.name, tagline: $0.tagline, description: $0.description, imageURL: $0.image_url, abv: $0.abv, ibu: $0.ibu)}
            return beers
        } catch {
            throw RemoteBeerListLoader.Error.invalidData
        }
    }
}

public final class RemoteBeerListLoader {
    private let url: URL
    private let client: HTTPClient
    
    public typealias Result = BeerListLoader.LoadResult
    
    public enum Error: Swift.Error {
        case invalidData
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
                completion(Result {
                    try RemoteBeerListMapper.map(data: data, from: response)
                })
            case .failure:
                completion(.failure(Error.invalidData))
            }
        })
    }
}
