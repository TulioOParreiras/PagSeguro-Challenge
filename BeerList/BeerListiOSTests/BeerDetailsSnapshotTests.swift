//
//  BeerDetailsSnapshotTests.swift
//  BeerListiOSTests
//
//  Created by Tulio Parreiras on 27/01/21.
//

import XCTest
@testable import BeerList
import BeerListiOS

class BeerDetailsSnapshotTests: XCTestCase {
    
    func test_beerDetailsWithContent() {
        let sut = makeSUT()
        
        sut.display(BeerDetailsStub(image: UIImage.make(withColor: .red)))
        
        record(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "BEER_DETAILS_WITH_CONTENT_light")
        record(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "BEER_DETAILS_WITH_CONTENT_dark")
    }
    
    func test_beerDetailsWithFailedImageLoading() {
        let sut = makeSUT()
        
        sut.display(BeerDetailsStub())
        
        record(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "BEER_DETAILS_WITH_FAILED_IMAGE_LOADING_light")
        record(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "BEER_DETAILS_WITH_FAILED_IMAGE_LOADING_dark")
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> BeerDetailsViewController {
        let bundle = Bundle(for: BeerDetailsViewController.self)
        let storyboard = UIStoryboard(name: "BeerDetails", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! BeerDetailsViewController
        controller.loadViewIfNeeded()
        return controller
    }
    
    private func emptyBeerList() -> [BeerCellController] {
        return []
    }
    
}

private extension BeerDetailsViewController {
    func display(_ stub: BeerDetailsStub) {
        self.delegate = stub
        stub.controller = self
        display(stub.viewModel)
    }
}

private class BeerDetailsStub: BeerDetailsViewControllerDelegate {
    let viewModel: BeerDetailsViewModel<UIImage>
    weak var controller: BeerDetailsViewController?
    
    init(name: String = "A name",
         description: String = "A description",
         ibuValue: Double? = nil,
         abvValue: Double = 5,
         tagline: String = "A tagline",
         image: UIImage? = nil) {
        self.viewModel = BeerDetailsViewModel(
            name: name,
            description: description,
            ibuValue: ibuValue,
            abvValue: abvValue,
            tagline: tagline,
            image: image,
            isLoading: false,
            shouldRetry: image == nil)
    }
    
    func didRequestBeerImageLoad() {
        controller?.display(viewModel)
    }
}

