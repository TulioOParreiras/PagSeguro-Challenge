//
//  SceneDelegateTests.swift
//  BeerListAppTests
//
//  Created by Tulio Parreiras on 26/01/21.
//

import XCTest
import BeerListiOS
@testable import BeerListApp

class SceneDelegateTests: XCTestCase {

    func test_sceneWillConnectToSession_configuresRootViewController() {
        let sut = SceneDelegate()
        sut.window = UIWindow()
        sut.configureWindow()
        
        let root = sut.window?.rootViewController
        let rootNavigation = root as? UINavigationController
        let topController = rootNavigation?.topViewController
        
        XCTAssertNotNil(rootNavigation, "Expected a navigation controller as root, got \(String(describing: root)) instead")
        XCTAssertTrue(topController is BeerListViewController, "Expected a beer list controller as top view controller \(String(describing: topController)) instead")
    }

}
