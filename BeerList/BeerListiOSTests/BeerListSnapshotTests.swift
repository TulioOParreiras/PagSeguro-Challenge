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
        
        record(snapshot: sut.snapshot(), named: "EMPTY_BEER_LIST")
    }
    
    func test_beerListWithContent() {
        let sut = makeSUT()
        
        sut.display(beerListWithContent())
        
        record(snapshot: sut.snapshot(), named: "BEER_LIST_WITH_CONTENT")
    }
    
    func test_beerListWithErrorMessage() {
        let sut = makeSUT()
        
        sut.display(.error(message: "This is a really long error message text to check how the view\nhandles multi-line\ntexts"))
        
        record(snapshot: sut.snapshot(), named: "BEER_LIST_WITH_ERROR_MESSAAGE")
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
    
    private func record(snapshot: UIImage, named name: String, file: StaticString = #file, line: UInt = #line) {
        guard let snapshotData = snapshot.pngData() else {
            XCTFail("Failed to generate PNG data representation from snapshot", file: file, line: line)
            return
        }
        
        let snapshotURL = URL(fileURLWithPath: String(describing: file))
            .deletingLastPathComponent()
            .appendingPathComponent("snapshots")
            .appendingPathComponent("\(name).png")
        
        do {
            try FileManager.default.createDirectory(
                at: snapshotURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            
            try snapshotData.write(to: snapshotURL)
        } catch {
            XCTFail("Failed to record snapshot with error: \(error)", file: file, line: line)
        }
    }
    
}

extension UIViewController {
    func snapshot() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
        return renderer.image { action in
            view.layer.render(in: action.cgContext)
        }
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

extension UIImage {
    static func make(withColor color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}
