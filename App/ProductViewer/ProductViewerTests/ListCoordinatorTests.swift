//
//  ProductViewerTests.swift
//  ProductViewerTests
//
//  Created by Satish Garlapati on 11/20/19.
//  Copyright © 2019 Target. All rights reserved.
//

import XCTest

@testable import ProductViewer
class ListCoordinatorTests: XCTestCase {

    /**
     We can do the same for detail Coordinator and when both coordinators are combined, one unit test class would suffice. Just not repeating myself becoz of time sensitivity
    */
    var listCoordinator: ListCoordinator!

    override func setUp() {
        super.setUp()
        listCoordinator = ListCoordinator()
    }

    /*
    It’s good practice creating coordinator in setUp() and releasing it in tearDown() to ensure every test starts with a clean slate
     */
    override func tearDown() {
        listCoordinator = nil
        super.tearDown()
    }
    
    func testCoordinatorInListViewController() {
        let viewController = ListViewController.viewControllerFor(coordinator: listCoordinator)
        XCTAssertNotNil(viewController.coordinator)
        XCTAssertNotNil(viewController.coordinator.presenters)
        XCTAssert(viewController.coordinator is ListCoordinator)
    }
    
    func testDispatcherOnCoordinator() {
        XCTAssertNotNil(listCoordinator.dispatcher)
    }
    
    func testViewStateOnCoordinator() {
        XCTAssertNotNil(listCoordinator.viewState)
    }
    
    /**
     Instead of testing fetchingDeals, we can also test the viewState.ListItems once the api is fetched
    */
    func testFetchingDealsFromAPI() {
        let promise = expectation(description: "target deals are not empty")
        NetworkManager.shared.fetchDeals { (targetResponse, error) in
            if let error = error {
                XCTFail("Error: \(error.localizedDescription)")
                return
            }
            guard let dealsResponse = targetResponse,
                !dealsResponse.deals.isEmpty else {
                    XCTFail("deals are empty")
                    return
            }
            promise.fulfill()
        }
        wait(for: [promise], timeout: 5)
    }
}
