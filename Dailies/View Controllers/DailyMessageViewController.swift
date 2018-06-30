//
//  DailyMessageViewController.swift
//  Dailies
//
//  Created by Banana Viking on 6/30/18.
//  Copyright © 2018 Banana Viking. All rights reserved.
//

import UIKit

class DailyMessageViewController: UIViewController {
    
    @IBAction func dismissDailyMessageVC(_ sender: UIButton) {
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
}
