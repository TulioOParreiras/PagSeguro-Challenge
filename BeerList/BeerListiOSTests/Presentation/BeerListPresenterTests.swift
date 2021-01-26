//
//  BeerListPresenterTests.swift
//  BeerListiOSTests
//
//  Created by Tulio Parreiras on 26/01/21.
//

import XCTest
import BeerList

class BeerListPresenterTests: XCTestCase {

    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()

        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    
    func test_didStartLoadingBeerList_displaysNoErrorMessageAndStartsLoading() {
        let (sut, view) = makeSUT()

        sut.didStartLoadingBeerList()
        
        XCTAssertEqual(view.messages, [
            .display(errorMessage: .none),
            .display(isLoading: true)
        ])
    }
    
    func test_didFinishLoadingBeerList_displaysBeerListAndStopsLoading() {
        let (sut, view) = makeSUT()
        let beerList = [makeBeer()]
        
        sut.didFinishLoadingBeerList(with: beerList)
        
        XCTAssertEqual(view.messages, [
            .display(beerList: beerList),
            .display(isLoading: false)
        ])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: BeerListPresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = BeerListPresenter(beerListView: view, loadingView: view, errorView: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }
    
    func makeBeer(name: String = "A name", imageURL: URL = URL(string: "https://a-url.com")!, ibu: Double? = nil) -> Beer {
        return Beer(id: Int.random(in: 0...100), name: name, tagline: "a tagline", description: "a description", imageURL: imageURL, abv: Double.random(in: 1...10), ibu: ibu)
    }

    private class ViewSpy: BeerListView, BeerListLoadingView, BeerListErrorView {
        enum Message: Hashable {
            case display(errorMessage: String?)
            case display(isLoading: Bool)
            case display(beerList: [Beer])
        }
        
        private(set) var messages = Set<Message>()
        
        func display(_ viewModel: BeerListErrorViewModel) {
            messages.insert(.display(errorMessage: viewModel.message))
        }
        
        func display(_ viewModel: BeerListLoadingViewModel) {
            messages.insert(.display(isLoading: viewModel.isLoading))
        }
        
        func display(_ viewModel: BeerListViewModel) {
            messages.insert(.display(beerList: viewModel.beerList))
        }
    }

}
