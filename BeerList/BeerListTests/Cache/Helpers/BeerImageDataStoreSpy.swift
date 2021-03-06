//
//  BeerImageDataStoreSpy.swift
//  BeerListTests
//
//  Created by Tulio Parreiras on 27/01/21.
//

import Foundation
import BeerList

class BeerImageDataStoreSpy: BeerImageDataStore {
    enum Message: Equatable {
        case insert(data: Data, for: URL)
        case retrieve(dataFor: URL)
    }
    private var retrievalCompletions = [(BeerImageDataStore.RetrievalResult) -> Void]()
    private var insertionCompletions = [(BeerImageDataStore.InsertionResult) -> Void]()

    private(set) var receivedMessages = [Message]()
    
    func insert(_ data: Data, for url: URL, completion: @escaping (BeerImageDataStore.InsertionResult) -> Void) {
        receivedMessages.append(.insert(data: data, for: url))
        insertionCompletions.append(completion)
    }

    func retrieve(dataForURL url: URL, completion: @escaping (BeerImageDataStore.RetrievalResult) -> Void) {
        receivedMessages.append(.retrieve(dataFor: url))
        retrievalCompletions.append(completion)
    }
    
    func completeRetrieval(with error: Error, at index: Int = 0) {
        retrievalCompletions[index](.failure(error))
    }
    
    func completeRetrieval(with data: Data?, at index: Int = 0) {
        retrievalCompletions[index](.success(data))
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionCompletions[index](.failure(error))
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionCompletions[index](.success(()))
    }
}
