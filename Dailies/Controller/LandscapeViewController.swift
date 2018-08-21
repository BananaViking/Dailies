//
//  LandscapeViewController.swift
//  Dailies
//
//  Created by Banana Viking on 6/9/18.
//  Copyright © 2018 Banana Viking. All rights reserved.
//

import UIKit

class LandscapeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let enemyImageView = view.viewWithTag(9000) as? UIImageView else { return }
        guard let enemyImage = UserDefaults.standard.object(forKey: "enemyImage") as? String else { return }
        enemyImageView.image = UIImage(named: enemyImage)
    }
}
