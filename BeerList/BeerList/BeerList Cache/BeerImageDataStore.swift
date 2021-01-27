//
//  BeerImageDataStore.swift
//  BeerList
//
//  Created by Tulio Parreiras on 27/01/21.
//

import Foundation

public protocol BeerImageDataStore {
    typealias Result = Swift.Result<Data?, Error>
    typealias InsertionResult = Swift.Result<Void, Error>

    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void)
    func retrieve(dataForURL url: URL, completion: @escaping (Result) -> Void)
}
