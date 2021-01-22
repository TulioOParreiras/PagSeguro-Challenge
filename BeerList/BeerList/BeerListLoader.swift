//
//  BeerListLoader.swift
//  BeerList
//
//  Created by Tulio Parreiras on 21/01/21.
//

import Foundation

protocol BeerListLoader  {
    typealias LoadResult = Swift.Result<Beer, Error>
    typealias LoadResponse = (LoadResult) -> Void
    
    func load(completion: @escaping LoadResponse)
}
