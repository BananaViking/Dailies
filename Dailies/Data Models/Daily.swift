//
//  Daily.swift
//  Dailies
//
//  Created by Banana Viking on 5/30/18.
//  Copyright © 2018 Banana Viking. All rights reserved.
//

import Foundation

class Daily: NSObject, Codable {
    var text = ""
    var checked = false
    var dueDate = Date()
    var shouldRemind = false
    var dailyID: Int
    
    override init() {
        dailyID = Daily.nextDailyID()
        super.init()
    }
    
    func toggleChecked() {
        checked = !checked 
    }
    
    class func nextDailyID() -> Int {
        let userDefaults = UserDefaults.standard
        let dailyID = userDefaults.integer(forKey: "DailyID")
        userDefaults.set(dailyID + 1, forKey: "DailyID")
        userDefaults.synchronize()
        return dailyID
    }
}
