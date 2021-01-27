//
//  CoreDataBeerStore+BeerImageDataStore.swift
//  BeerList
//
//  Created by Tulio Parreiras on 27/01/21.
//

import Foundation

extension CoreDataBeerStore: BeerImageDataStore {
    
    public func insert(_ data: Data, for url: URL, completion: @escaping (BeerImageDataStore.InsertionResult) -> Void) {
        perform { context in
            completion(Result {
                let managedBeerImage = try ManagedBeerImage.newUniqueInstance(in: context)
                managedBeerImage.data = data
                managedBeerImage.url = url
                try context.save()
            })
        }
    }
    
    public func retrieve(dataForURL url: URL, completion: @escaping (BeerImageDataStore.RetrievalResult) -> Void) {
        perform { context in
            completion(Result {
                try ManagedBeerImage.first(with: url, in: context)?.data
            })
        }
    }
    
}
