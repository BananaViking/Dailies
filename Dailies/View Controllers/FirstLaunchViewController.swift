//
//  FirstLaunchViewController.swift
//  Dailies
//
//  Created by Banana Viking on 6/30/18.
//  Copyright © 2018 Banana Viking. All rights reserved.
//

import UIKit

class FirstLaunchViewController: UIViewController {
    
    @IBAction func startGameButton(_ sender: UIButton) {
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
}
