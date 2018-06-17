//
//  PlayerStats.swift
//  Dailies
//
//  Created by Banana Viking on 6/9/18.
//  Copyright © 2018 Banana Viking. All rights reserved.
//

import UIKit

class PlayerStatsViewController: UITableViewController {
    
    var landscapeVC: LandscapeViewController?
    var playerStats = PlayerStats()

    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var nextLevelStreakLabel: UILabel!
    @IBOutlet weak var daysMissedStreakLabel: UILabel!
    @IBOutlet weak var highestLevelLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabels()
        self.tableView.allowsSelection = false 
    }
    
    func updateLabels() {
        levelLabel.text = "\(UserDefaults.standard.object(forKey: "level") ?? "1")"
        rankLabel.text = "\(UserDefaults.standard.object(forKey: "rank") ?? "Novice")"
        nextLevelStreakLabel.text = "\(UserDefaults.standard.object(forKey: "streak") ?? "2")" // change to 7 on launch
        daysMissedStreakLabel.text = "\(UserDefaults.standard.object(forKey: "daysMissed") ?? "0")"
        highestLevelLabel.text = "\(UserDefaults.standard.object(forKey: "highestLevel") ?? "1")"
    }
    
    // MARK: - Landscape
    // landscape transition
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        
        switch newCollection.verticalSizeClass {
        case .compact:
            showLandscape(with: coordinator)
        case .regular, .unspecified:
            hideLandscape(with: coordinator)
        }
    }
    
    func showLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
        guard landscapeVC == nil else { return }
        landscapeVC = storyboard!.instantiateViewController(withIdentifier: "LandscapeViewController") as? LandscapeViewController
        
        if let controller = landscapeVC {
            controller.view.frame = view.frame  // was view.bounds but was showing table rows at bottom
            // alpha 0 to 1 makes the transition fade in
            controller.view.alpha = 0
            view.addSubview(controller.view)
            addChildViewController(controller)
            coordinator.animate(alongsideTransition: { _ in
                controller.view.alpha = 1
            }, completion: { _ in
                controller.didMove(toParentViewController: self)
            })
            //            self.navigationItem.title = "Your Kingdom"
            self.navigationController?.isNavigationBarHidden = true
        }
    }
    
    func hideLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
        if let controller = landscapeVC {
            controller.willMove(toParentViewController: nil)
            
            coordinator.animate(alongsideTransition: { _ in
                controller.view.alpha = 0
            }, completion: { _ in
                controller.view.removeFromSuperview()
                controller.removeFromParentViewController()
                self.landscapeVC = nil
                //                self.navigationItem.title = "Dailies"
                self.navigationController?.isNavigationBarHidden = false
            })
        }
    }
}
