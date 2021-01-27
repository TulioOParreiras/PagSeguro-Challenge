//
//  XCTest+SharedHelpers.swift
//  BeerListAppTests
//
//  Created by Tulio Parreiras on 27/01/21.
//

import UIKit
import BeerList

func anyNSError() -> NSError {
    return NSError(domain: "A domain", code: 1)
}

func anyImageData() -> Data {
    return UIImage.make(withColor: .red).pngData()!
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
