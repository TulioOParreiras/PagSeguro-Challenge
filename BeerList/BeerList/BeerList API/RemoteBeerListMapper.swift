//
//  RemoteBeerListMapper.swift
//  BeerList
//
//  Created by Tulio Parreiras on 22/01/21.
//

import Foundation

final class RemoteBeerListMapper {
    
    private struct BeerItem: Decodable {
        let id: Int
        let name: String
        let tagline: String
        let description: String
        let image_url: URL
        let abv: Double
        let ibu: Double
        
        var item: Beer {
            Beer(id: self.id,
                 name: self.name,
                 tagline: self.tagline,
                 description: self.description,
                 imageURL: self.image_url,
                 abv: self.abv,
                 ibu: self.ibu)
        }
    }
    
    static func map(data: Data, from response: HTTPURLResponse) throws -> [Beer] {
        guard (response as HTTPURLResponse).statusCode == 200 else {
            throw RemoteBeerListLoader.Error.invalidData
        }
        do {
            let item = try JSONDecoder().decode([BeerItem].self, from: data)
            let beers = item.compactMap { $0.item }
            return beers
        } catch {
            throw RemoteBeerListLoader.Error.invalidData
        }
    }
}
