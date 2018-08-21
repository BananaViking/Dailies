//
//  PlayerStats.swift
//  Dailies
//
//  Created by Banana Viking on 6/9/18.
//  Copyright © 2018 Banana Viking. All rights reserved.
//
import Foundation

class PlayerInfo: NSObject, Codable {
    var quest = "Skeleton Quest"
    var level = 1
    var rank = "Neophyte"
    var playerImage = "wizard1"
    var enemyImage = "enemy1"
    var launchedBefore = false
    var isNewDay = true
    var dailiesDone = 0
    var daysTil = 3 // change to 7 on launch
    var daysMissed = 0
    var perfectDay = false
    var gainedLevel = false
    var lostLevel = false
    var beatGame = false
    var lostGame = false
    
    func calculateLevelInfo() {
        level = UserDefaults.standard.integer(forKey: "level")
        
        switch level {
        case 1:
            quest = "Skeleton Quest"
            rank = "Apprentice"
            playerImage = "wizard1"
            enemyImage = "enemy1"
        case 2:
            quest = "Goblin Quest"
            rank = "Initiate"
            playerImage = "wizard2"
            enemyImage = "enemy2"
        case 3:
            quest = "Witch Quest"
            rank = "Adept"
            playerImage = "wizard3"
            enemyImage = "enemy3"
        case 4:
            quest = "Vampire Quest"
            rank = "Mage"
            playerImage = "wizard4"
            enemyImage = "enemy4"
        case 5:
            quest = "Faceless Mage Quest"
            rank = "Battle Mage"
            playerImage = "wizard5"
            enemyImage = "enemy5"
        case 6:
            quest = "Vampire Queen Quest"
            rank = "Archmage"
            playerImage = "wizard6"
            enemyImage = "enemy6"
        case 7:
            quest = "Draconian Quest"
            rank = "Wizard"
            playerImage = "wizard7"
            enemyImage = "enemy7"
        case 8:
            quest = "Ice Queen Quest"
            rank = "Master Wizard"
            playerImage = "wizard8"
            enemyImage = "enemy8"
        case 9:
            quest = "Pyromancer Quest"
            rank = "Grandmaster Wizard"
            playerImage = "wizard9"
            enemyImage = "enemy9"
        case 10:
            quest = "Necromancer Quest"
            rank = "The Enlightened"
            playerImage = "wizard10"
            enemyImage = "enemy10"
        default:
            print("error")
        }

        // these are needed unless you call calculateLevelInfo EVERY time you need to access one of these values
        UserDefaults.standard.set(quest, forKey: "quest")
        UserDefaults.standard.set(rank, forKey: "rank")
        UserDefaults.standard.set(playerImage, forKey: "playerImage")
        UserDefaults.standard.set(enemyImage, forKey: "enemyImage")
    }
}
