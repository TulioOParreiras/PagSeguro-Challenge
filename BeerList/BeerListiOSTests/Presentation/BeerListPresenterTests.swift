//
//  BeerListPresenterTests.swift
//  BeerListiOSTests
//
//  Created by Tulio Parreiras on 26/01/21.
//

import XCTest

struct BeerListLoadingViewModel {
    let isLoading: Bool
}

protocol BeerListLoadingView {
    func display(_ viewModel: BeerListLoadingViewModel)
}

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
    private let loadingView: BeerListLoadingView
    private let errorView: BeerListErrorView
    
    init(loadingView: BeerListLoadingView,errorView: BeerListErrorView) {
        self.loadingView = loadingView
        self.errorView = errorView
    }
    
    func didStartLoadingBeerList() {
        errorView.display(.noError)
        loadingView.display(BeerListLoadingViewModel(isLoading: true))
    }
}

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
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: BeerListPresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = BeerListPresenter(loadingView: view, errorView: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }

    private class ViewSpy: BeerListLoadingView, BeerListErrorView {
        enum Message: Equatable {
            case display(errorMessage: String?)
            case display(isLoading: Bool)
        }
        
        private(set) var messages = [Message]()
        
        func display(_ viewModel: BeerListErrorViewModel) {
            messages.append(.display(errorMessage: viewModel.message))
        }
        
        func display(_ viewModel: BeerListLoadingViewModel) {
            messages.append(.display(isLoading: viewModel.isLoading))
        }
    }

}
