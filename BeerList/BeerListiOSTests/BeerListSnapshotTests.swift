//
//  BeerListSnapshotTests.swift
//  BeerListiOSTests
//
//  Created by Tulio Parreiras on 26/01/21.
//

import XCTest
@testable import BeerList
import BeerListiOS

class BeerListSnapshotTests: XCTestCase {

    func test_emptyBeerList() {
        let sut = makeSUT()
        
        sut.display(emptyBeerList())
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "EMPTY_BEER_LIST_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "EMPTY_BEER_LIST_dark")
    }
    
    func test_beerListWithContent() {
        let sut = makeSUT()
        
        sut.display(beerListWithContent())
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "BEER_LIST_WITH_CONTENT_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "BEER_LIST_WITH_CONTENT_dark")
    }
    
    func test_beerListWithErrorMessage() {
        let sut = makeSUT()
        
        sut.display(.error(message: "This is a really long error message text to check how the view\nhandles multi-line\ntexts"))
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "BEER_LIST_WITH_ERROR_MESSAAGE_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "BEER_LIST_WITH_ERROR_MESSAAGE_dark")
    }
    
    func test_beerWithFailedImageLoading() {
        let sut = makeSUT()
        
        sut.display(beerWithFailedImageLoading())
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "BEER_WITH_FAILED_IMAGE_LOADING_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "BEER_WITH_FAILED_IMAGE_LOADING_dark")
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> BeerListViewController {
        let bundle = Bundle(for: BeerListViewController.self)
        let storyboard = UIStoryboard(name: "BeerList", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! BeerListViewController
        controller.loadViewIfNeeded()
        return controller
    }
    
    private func emptyBeerList() -> [BeerCellController] {
        return []
    }
    
    private func beerListWithContent() -> [BeerStub] {
        return [
            BeerStub(name: "Buzz", ibu: 60.0, image: UIImage.make(withColor: .red)),
            BeerStub(name: "Trashy Blonde", ibu: 41.5, image: UIImage.make(withColor: .blue))
        ]
    }
    
    private func beerWithFailedImageLoading() -> [BeerStub] {
        return [
            BeerStub(name: "Buzz", ibu: 60.0, image: nil),
            BeerStub(name: "Trashy Blonde", ibu: 41.5, image: nil)
        ]
    }
    
}

private extension BeerListViewController {
    func display(_ stubs: [BeerStub]) {
        let cells: [BeerCellController] = stubs.map { stub in
            let cellController = BeerCellController(delegate: stub, selection: { })
            stub.controller = cellController
            return cellController
        }
        
        display(cells)
    }
}

private class BeerStub: BeerCellControllerDelegate {
    let viewModel: BeerViewModel<UIImage>
    weak var controller: BeerCellController?
    
    init(name: String, ibu: Double?, image: UIImage?) {
        self.viewModel = BeerViewModel(
            name: name,
            ibuValue: ibu,
            image: image,
            isLoading: false,
            shouldRetry: image == nil)
    }
    
    func didRequestImage() {
        controller?.display(viewModel)
    }
    
    func didCancelImageRequest() {
        
    }
}
