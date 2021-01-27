//
//  BeerDetailsViewControllerTests.swift
//  BeerListiOSTests
//
//  Created by Tulio Parreiras on 26/01/21.
//

import XCTest
import BeerList

final class BeerDetailsViewController: UIViewController {
    convenience init(model: Beer) {
        self.init()
        self.title = model.name
    }
}

class BeerDetailsViewControllerTests: XCTestCase {

    func test_beerDetailsView_hasTitle() {
        let model = makeBeer()
        let sut = BeerDetailsViewController(model: model)
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.title, model.name)
    }
    
    func makeBeer(name: String = "A name", imageURL: URL = URL(string: "https://a-url.com")!, ibu: Double? = nil) -> Beer {
        return Beer(id: Int.random(in: 0...100), name: name, tagline: "a tagline", description: "a description", imageURL: imageURL, abv: Double.random(in: 1...10), ibu: ibu)
    }

}
