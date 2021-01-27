//
//  BeerListViewControllerTests+Assertions.swift
//  BeerListiOSTests
//
//  Created by Tulio Parreiras on 25/01/21.
//

import XCTest
import BeerList
import BeerListiOS


extension BeerListUIIntegrationsTests {
    
    func assertThat(_ sut: BeerListViewController, isRendering beerList: [Beer], file: StaticString = #file, line: UInt = #line) {
        sut.tableView.layoutIfNeeded()
        RunLoop.main.run(until: Date())
        
        guard sut.numberOfRenderedBeerCells() == beerList.count else {
            return XCTFail("Expected \(beerList.count) beer items, got \(sut.numberOfRenderedBeerCells()) instead", file: file, line: line)
        }
        
        beerList.enumerated().forEach { index, beer in
            assertThat(sut, hasViewConfiguredFor: beer, at: index, file: file, line: line)
        }
    }
    
    func assertThat(_ sut: BeerListViewController, hasViewConfiguredFor beer: Beer, at index: Int, file: StaticString = #file, line: UInt = #line) {
        let view = sut.beerCell(at: index)
        
        guard let cell = view as? BeerCell else {
            return XCTFail("Expected \(BeerCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
        }
        
        let expectedAbvText = "ABV: \(beer.abv)"
        XCTAssertEqual(cell.abvText, expectedAbvText, "Expected abv text to be \(expectedAbvText) for beer cell at index (\(index))", file: file, line: line)
        XCTAssertEqual(cell.nameText, beer.name, "Expected name text to be \(beer.name) for beer cell at index (\(index))", file: file, line: line)
    }
    
}
