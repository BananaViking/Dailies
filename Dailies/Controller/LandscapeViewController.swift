//
//  LandscapeViewController.swift
//  Dailies
//
//  Created by Banana Viking on 6/9/18.
//  Copyright © 2018 Banana Viking. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

class LandscapeViewController: UIViewController {
    
    var enemyImage = UserDefaults.standard.object(forKey: "enemyImage") as? String

    override func viewDidLoad() {
        super.viewDidLoad()

        let enemyImageView = self.view.viewWithTag(9000) as! UIImageView
        enemyImageView.image = UIImage(named: enemyImage!)
    }
}
