//
//  BeerImageDataStore.swift
//  BeerList
//
//  Created by Tulio Parreiras on 27/01/21.
//

import Foundation

public protocol BeerImageDataStore {
    typealias Result = Swift.Result<Data?, Error>

    func retrieve(dataForURL url: URL, completion: @escaping (Result) -> Void)
}
