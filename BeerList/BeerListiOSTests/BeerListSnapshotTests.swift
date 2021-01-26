//
//  BeerListSnapshotTests.swift
//  BeerListiOSTests
//
//  Created by Tulio Parreiras on 26/01/21.
//

import XCTest
import BeerList
import BeerListiOS

class BeerListSnapshotTests: XCTestCase {

    func test() {
        let sut = makeSUT()
        
        sut.tableModel = emptyBeerList()
        
        record(snapshot: sut.snapshot(), named: "EMPTY_BEER_LIST")
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
