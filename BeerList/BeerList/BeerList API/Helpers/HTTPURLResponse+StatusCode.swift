//
//  HTTPURLResponse+StatusCode.swift
//  BeerList
//
//  Created by Tulio Parreiras on 26/01/21.
//

import Foundation

extension HTTPURLResponse {
    private static var OK_200: Int { return 200 }

    var isOK: Bool {
        return statusCode == HTTPURLResponse.OK_200
    }
}
