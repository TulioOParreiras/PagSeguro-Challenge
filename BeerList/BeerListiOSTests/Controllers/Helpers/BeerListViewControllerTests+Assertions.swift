//
//  BeerListViewControllerTests+Assertions.swift
//  BeerListiOSTests
//
//  Created by Tulio Parreiras on 25/01/21.
//

import XCTest
import BeerList
import BeerListiOS


extension BeerListViewControllerTests {
    
    func assertThat(_ sut: BeerListViewController, isRendering beerList: [Beer], file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(sut.numberOfRenderedBeerCells(), beerList.count, "Expected \(beerList.count) beers, got \(sut.numberOfRenderedBeerCells()) instead", file: file, line: line)
        
        beerList.enumerated().forEach { index, beer in
            assertThat(sut, hasViewConfiguredFor: beer, at: index, file: file, line: line)
        }
    }
    
    func assertThat(_ sut: BeerListViewController, hasViewConfiguredFor beer: Beer, at index: Int, file: StaticString = #file, line: UInt = #line) {
        let view = sut.beerCell(at: index)
        
        guard let cell = view as? BeerCell else {
            return XCTFail("Expected \(BeerCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
        }
        
        let shouldIbuBeVisible = beer.ibu != nil
        XCTAssertEqual(cell.isShowingIbu, shouldIbuBeVisible, "Expected `isShowingIbu` to be \(shouldIbuBeVisible) for beer cell at index (\(index))", file: file, line: line)
        
        XCTAssertEqual(cell.nameText, beer.name, "Expected name text to be \(beer.name) for beer cell at index (\(index))", file: file, line: line)
    }
    
    func makeBeer(name: String = "A name", imageURL: URL = URL(string: "https://a-url.com")!, ibu: Double? = nil) -> Beer {
        return Beer(id: Int.random(in: 0...100), name: name, tagline: "a tagline", description: "a description", imageURL: imageURL, abv: Double.random(in: 1...10), ibu: ibu)
    }
    
}
