//
//  URLSessionHTTPClient.swift
//  BeerList
//
//  Created by Tulio Parreiras on 24/01/21.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    private struct UnexpectedValuesRepresentation: Error { }
    
    private struct URLSessionTaskWrapper: HTTPClientTask {
        let wrapped: URLSessionTask
        
        func cancel() {
            wrapped.cancel()
        }
    }

    public func get(from url: URL, completion: @escaping(HTTPClient.Result) -> Void) -> HTTPClientTask {
        let task = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let httpURLResponse = response as? HTTPURLResponse {
                completion(.success((data, httpURLResponse)))
            } else {
                completion(.failure(UnexpectedValuesRepresentation()))
            }
        }
        task.resume()
        return URLSessionTaskWrapper(wrapped: task)
    }
}
