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
    
    var player = PlayerInfo()
    let vc = DailiesViewController()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCalculateLevelInfo() {
        UserDefaults.standard.set(10, forKey: "level")
        player.calculateLevelInfo()
        XCTAssert(player.quest == "Necromancer Quest", "calculateLevelInfo not working for rank.")
        XCTAssert(player.rank == "Grandmaster Wizard", "calculateLevelInfo not working for rank.")
        XCTAssert(player.playerImage == "wizard10", "calculateLevelInfo not working for rank.")
        XCTAssert(player.enemyImage == "enemy10", "calculateLevelInfo not working for enemyImage")
    }
    
    func testLoseLevel() {
        
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
