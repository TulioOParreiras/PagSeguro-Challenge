//
//  SharedTestHelpers.swift
//  BeerListTests
//
//  Created by Tulio Parreiras on 26/01/21.
//

import Foundation

func anyNSError() -> NSError {
    return NSError(domain: "a domain", code: 1)
}

func anyURL() -> URL {
    return URL(string: "https://any-url.com")!
}

func anyData() -> Data {
    return Data("any data".utf8)
}
