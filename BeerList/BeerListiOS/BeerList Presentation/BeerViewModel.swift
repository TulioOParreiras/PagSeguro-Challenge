//
//  BeerViewModel.swift
//  BeerListiOS
//
//  Created by Tulio Parreiras on 25/01/21.
//

import Foundation

struct BeerViewModel<Image> {
    let name: String
    let ibuValue: Double?
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool
    
    var ibu: String?  {
        guard let ibu = ibuValue else { return nil }
        return String(describing: ibu)
    }
    
    var hasIbu: Bool {
        return ibuValue != nil
    }
}
