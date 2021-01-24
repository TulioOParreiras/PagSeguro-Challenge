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
