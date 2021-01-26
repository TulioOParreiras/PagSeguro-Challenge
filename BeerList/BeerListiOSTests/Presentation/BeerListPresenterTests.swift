//
//  BeerListPresenterTests.swift
//  BeerListiOSTests
//
//  Created by Tulio Parreiras on 26/01/21.
//

import XCTest

struct BeerListErrorViewModel {
    let message: String?
    
    static var noError: BeerListErrorViewModel {
        return BeerListErrorViewModel(message: nil)
    }
}

protocol BeerListErrorView {
    func display(_ viewModel: BeerListErrorViewModel)
}

final class BeerListPresenter {
    private let errorView: BeerListErrorView
    
    init(errorView: BeerListErrorView) {
        self.errorView = errorView
    }
    
    func didStartLoadingBeerList() {
        errorView.display(.noError)
    }
}

class BeerListPresenterTests: XCTestCase {

    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()

        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    
    func test_didStartLoadingBeerLIsst_displaysNoErrorMessage() {
        let (sut, view) = makeSUT()

        sut.didStartLoadingBeerList()

        XCTAssertEqual(view.messages, [.display(errorMessage: .none)])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: BeerListPresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = BeerListPresenter(errorView: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }

    private class ViewSpy: BeerListErrorView {
        enum Message: Equatable {
            case display(errorMessage: String?)
        }
        
        private(set) var messages = [Message]()
        
        func display(_ viewModel: BeerListErrorViewModel) {
            messages.append(.display(errorMessage: viewModel.message))
        }

    }

}
