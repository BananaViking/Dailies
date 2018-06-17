//
//  PlayerStats.swift
//  Dailies
//
//  Created by Banana Viking on 6/9/18.
//  Copyright © 2018 Banana Viking. All rights reserved.
//

import Foundation

class PlayerStats: NSObject, Codable {
    
    var level = 1
    var rank = "Neophyte"
    var streak = 2 // change to 7 on launch
    var daysMissed = 0
    var highestLevel = 1
}
