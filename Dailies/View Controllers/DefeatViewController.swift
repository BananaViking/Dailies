//
//  DefeatViewController.swift
//  Dailies
//
//  Created by Banana Viking on 6/30/18.
//  Copyright © 2018 Banana Viking. All rights reserved.
//

import UIKit

class DefeatViewController: UIViewController {
    
    let vc = DailiesViewController()

    @IBAction func dismissDefeatVC(_ sender: UIButton) {
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        vc.playSound(forObject: "resetGame")
        UserDefaults.standard.set(1, forKey: "level")
        UserDefaults.standard.set(2, forKey: "daysTil")  // change to 7 on launch
        UserDefaults.standard.set(0, forKey: "daysMissed")
    }
}
