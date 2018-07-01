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
    
    override func viewDidLoad() {
        if let advisorImageView = self.view.viewWithTag(43) as? UIImageView {
            advisorImageView.layer.cornerRadius = 20    
            advisorImageView.image = UIImage(named: "advisorHappy")
        }
    }
}
