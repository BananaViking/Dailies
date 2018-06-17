//
//  PlayerStats.swift
//  Dailies
//
//  Created by Banana Viking on 6/9/18.
//  Copyright © 2018 Banana Viking. All rights reserved.
//

import UIKit

class QuestInfoViewController: UITableViewController {
    
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var nextLevelStreakLabel: UILabel!
    @IBOutlet weak var daysMissedStreakLabel: UILabel!
    @IBOutlet weak var questLabel: UILabel!
    
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
        questLabel.text = UserDefaults.standard.object(forKey: "quest") as? String ?? "Skeleton Quest"
    }
}
