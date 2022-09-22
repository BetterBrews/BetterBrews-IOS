//
//  BetterBrewsTests.swift
//  BetterBrewsTests
//
//  Created by Colby Haskell on 8/27/22.
//

import XCTest
@testable import BetterBrews

class BrewsManagerTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.hnm
    }

    func testNewBrewProcess() throws {
        let testBrew = Brew("Hario V60")
        
        // Save Test Brew
        BrewsManager.saveBrew(testBrew)
        
        // Fetch all stored brews
//        _pastBrews = FetchRequest(fetchRequest: request)
    
        // Ensure the saved brew is the only view
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
