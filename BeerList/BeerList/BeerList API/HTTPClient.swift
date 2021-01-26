//
//  HTTPClient.swift
//  BeerList
//
//  Created by Tulio Parreiras on 22/01/21.
//

import Foundation

public protocol HTTPClientTask {
    func cancel()
}

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    typealias Response = (Result) -> Void
    
    @discardableResult
    func get(from url: URL, completion: @escaping (Result) -> Void) -> HTTPClientTask
}
