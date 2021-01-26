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
        
        sut.tableModel = emptyBeerList()
        
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
    
    private func assert(snapshot: UIImage, named name: String, file: StaticString = #file, line: UInt = #line) {
        let snapshotURL = makeSnapshotURL(named: name, file: file)
        let snapshotData = makeSnapshotData(for: snapshot, file: file, line: line)
        
        guard let storedSnapshotData = try? Data(contentsOf: snapshotURL) else {
            XCTFail("Failed to load stored snapshot at URL: \(snapshotURL). Use the `record` method to store a snapshot before asserting.", file: file, line: line)
            return
        }
        
        if snapshotData != storedSnapshotData {
            let temporarySnapshotURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
                .appendingPathComponent(snapshotURL.lastPathComponent)
            
            try? snapshotData?.write(to: temporarySnapshotURL)
            
            XCTFail("New snapshot does not match stored snapshot. New snapshot URL: \(temporarySnapshotURL), Stored snapshot URL: \(snapshotURL)", file: file, line: line)
        }
    }
    
    private func record(snapshot: UIImage, named name: String, file: StaticString = #file, line: UInt = #line) {
        let snapshotURL = makeSnapshotURL(named: name, file: file)
        let snapshotData = makeSnapshotData(for: snapshot, file: file, line: line)
        
        do {
            try FileManager.default.createDirectory(
                at: snapshotURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            
            try snapshotData?.write(to: snapshotURL)
        } catch {
            XCTFail("Failed to record snapshot with error: \(error)", file: file, line: line)
        }
    }
    
    private func makeSnapshotURL(named name: String, file: StaticString) -> URL {
        return URL(fileURLWithPath: String(describing: file))
            .deletingLastPathComponent()
            .appendingPathComponent("snapshots")
            .appendingPathComponent("\(name).png")
    }
    
    private func makeSnapshotData(for snapshot: UIImage, file: StaticString, line: UInt) -> Data? {
        guard let data = snapshot.pngData() else {
            XCTFail("Failed to generate PNG data representation from snapshot", file: file, line: line)
            return nil
        }
        
        return data
    }
    
}

private extension BeerListViewController {
    func display(_ stubs: [BeerStub]) {
        let cells: [BeerCellController] = stubs.map { stub in
            let cellController = BeerCellController(delegate: stub)
            stub.controller = cellController
            return cellController
        }
        
        tableModel = cells
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
