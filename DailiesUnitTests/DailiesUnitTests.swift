//
//  DailiesUnitTests.swift
//  DailiesUnitTests
//
//  Created by Banana Viking on 6/28/18.
//  Copyright © 2018 Banana Viking. All rights reserved.
//

import XCTest
@testable import Dailies

class DailiesUnitTests: XCTestCase {
    
    var player = QuestInfo()
    let vc = DailiesViewController()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRank() {
        UserDefaults.standard.set(10, forKey: "level")
        player.calculateLevelInfo()
        XCTAssert(player.rank == "Grandmaster Wizard", "calculateLevelInfo not working for rank.")
    }
    
    func testEnemyImage() {
        UserDefaults.standard.set(7, forKey: "level")
        player.calculateLevelInfo()
        XCTAssert(player.enemyImage == "enemy7", "calculateLevelInfo not working for enemyImage")
    }
    
    func testLoseLevel() {
        player.daysMissed = 1
        
        
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
