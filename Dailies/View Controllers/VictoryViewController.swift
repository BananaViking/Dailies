//
//  VictoryViewController.swift
//  Dailies
//
//  Created by Banana Viking on 6/29/18.
//  Copyright © 2018 Banana Viking. All rights reserved.
//

import UIKit

class VictoryViewController: UIViewController {
    
    let vc = DailiesViewController()
    
    @IBAction func resetGame(_ sender: UIButton) {
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        vc.resetGame()
        vc.playSound(forObject: "resetGame")
        vc.resetDailies()
        UserDefaults.standard.set(1, forKey: "level")
        UserDefaults.standard.set(2, forKey: "daysTil")  // change to 7 on launch
        UserDefaults.standard.set(0, forKey: "daysMissed")
        vc.player.calculateLevelInfo()
        //        vc.updatePlayerImage()
        vc.dailies.removeAll()
        vc.saveDailies()
        //       vc.tableView.reloadData()
    }
}
