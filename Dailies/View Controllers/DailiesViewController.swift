//
//  ViewController.swift
//  Dailies
//
//  Created by Banana Viking on 5/30/18.
//  Copyright © 2018 Banana Viking. All rights reserved.
//

import UIKit

class DailiesViewController: UITableViewController, DailyDetailViewControllerDelegate {
    
    var landscapeVC: LandscapeViewController?
    var playerStats = PlayerStats()
    var dailies = [Daily]()
    var dailiesDone = 0
    var gainedLevel = false
    var lostLevel = false
    
    // MARK: - DailyDetailVC Protocols
    func dailyDetailViewControllerDidCancel(_ controller: DailyDetailViewController) {
        navigationController?.popViewController(animated: true)
    }
    
    func dailyDetailViewController(_ controller: DailyDetailViewController, didFinishAdding daily: Daily) {
        let newRowIndex = dailies.count
        dailies.append(daily)
        
        let indexPath = IndexPath(row: newRowIndex, section: 0)
        let indexPaths = [indexPath]
        tableView.insertRows(at: indexPaths, with: .automatic)
        navigationController?.popViewController(animated: true)
        saveDailies()
    }
    
    func dailyDetailViewController(_ controller: DailyDetailViewController, didFinishEditing daily: Daily) {
        if let index = dailies.index(of: daily) {
            let indexPath = IndexPath(row: index, section: 0)
            if let cell = tableView.cellForRow(at: indexPath) {
                configureText(for: cell, with: daily)
            }
        }
        navigationController?.popViewController(animated: true)
        saveDailies()
    }
    
    // MARK: - main overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        playerStats.streak = UserDefaults.standard.integer(forKey: "streak")
        playerStats.level = UserDefaults.standard.integer(forKey: "level")
        playerStats.daysMissed = UserDefaults.standard.integer(forKey: "daysMissed")
        playerStats.highestLevel = UserDefaults.standard.integer(forKey: "highestLevel")
        
        
        
        if playerStats.level == 0 {
            playerStats.level = 1
        }
        
        
        loadDailies()
        checkDailiesComplete()
        checkLastLaunch()
        calculateRank()
        resetDailies()
        
        let wizardImage = self.view.viewWithTag(600) as! UIImageView
        if playerStats.level == 1 {
            wizardImage.image = UIImage(named: "wizard1")
            navigationItem.title = "Skeleton Quest"
        } else if playerStats.level == 2 {
            wizardImage.image = UIImage(named: "wizard2")
            navigationItem.title = "Goblin Quest"
        } else if playerStats.level == 3 {
            wizardImage.image = UIImage(named: "wizard3")
            navigationItem.title = "Witch Quest"
        } else if playerStats.level == 4 {
            wizardImage.image = UIImage(named: "wizard4")
            navigationItem.title = "Vampire Quest"
        } else if playerStats.level == 5 {
            wizardImage.image = UIImage(named: "wizard5")
            navigationItem.title = "Faceless Mage Quest"
        } else if playerStats.level == 6 {
            wizardImage.image = UIImage(named: "wizard6")
            navigationItem.title = "Vampire Queen Quest"
        } else if playerStats.level == 7 {
            wizardImage.image = UIImage(named: "wizard7")
            navigationItem.title = "Draconian Quest"
        } else if playerStats.level == 8 {
            wizardImage.image = UIImage(named: "wizard8")
            navigationItem.title = "Ice Queen Quest"
        } else if playerStats.level == 9 {
            wizardImage.image = UIImage(named: "wizard9")
            navigationItem.title = "Pyromancer Quest"
        } else if playerStats.level > 9 {
            wizardImage.image = UIImage(named: "wizard10")
            navigationItem.title = "Necromancer Quest"
        }

    }
    
    // MARK: - tableView Delegates
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dailies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "daily", for: indexPath)
        let daily = dailies[indexPath.row]
        
        configureText(for: cell, with: daily)
        configureCheckmark(for: cell, with: daily)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) {
            let daily = dailies[indexPath.row]
            daily.toggleChecked()
            configureCheckmark(for: cell, with: daily)
            if daily.checked {
                dailiesDone += 1
                print("\(dailiesDone) out of \(dailies.count) completed.")
            } else {
                if dailiesDone > 0 {
                    dailiesDone -= 1
                    print("\(dailiesDone) out of \(dailies.count) completed.")
                }
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        saveDailies()
    }
    
    // enables swipe to delete rows
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        let daily = dailies[indexPath.row]
        if daily.checked {
            if dailiesDone > 0 {
                dailiesDone -= 1
            }
        }
        dailies.remove(at: indexPath.row)
        
        let indexPaths = [indexPath]
        tableView.deleteRows(at: indexPaths, with: .automatic)
        print("\(dailiesDone) out of \(dailies.count) completed.")
        saveDailies()
    }
    
    // MARK: - Functions
    func configureCheckmark(for cell: UITableViewCell,
                            with daily: Daily) {
        let label = cell.viewWithTag(1001) as! UILabel
        
        if daily.checked {
            label.text = "√"
        } else {
            label.text = ""
        }
    }
    
    func configureText(for cell: UITableViewCell, with daily: Daily) {
        let label = cell.viewWithTag(1000) as! UILabel
        label.text = daily.text
    }
    
    // gets full path to the Documents folder
    func documentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        return paths[0]
    }
    
    func dataFilePath() -> URL {
        return documentsDirectory().appendingPathComponent("Dailies.plist")
    }
    
    // takes contents of dailies array, converts to block of binary data, and writes it to a file
    func saveDailies() {
        let encoder = PropertyListEncoder()
        
        do {
            let data = try encoder.encode(dailies)
            
            try data.write(to: dataFilePath(), options: Data.WritingOptions.atomic)
        } catch {
            print("Error encoding daily array.")
        }
    }
    
    func loadDailies() {
        let path = dataFilePath()
        
        if let data = try? Data(contentsOf: path) {
            let decoder = PropertyListDecoder()
            
            do {
                dailies = try decoder.decode([Daily].self, from: data)
            } catch {
                print("Error decoding daily array.")
            }
        }
        
        for daily in dailies where daily.checked {
            dailiesDone += 1
        }
    }
    
    func resetDailies() {
        for daily in dailies {
            if daily.checked {
                daily.checked = false
            }
        }
        
        dailiesDone = 0
        saveDailies()
    }
    
    func checkDailiesComplete() {
        if dailiesDone == dailies.count {
            if playerStats.streak > 0 {
            playerStats.streak -= 1
            playerStats.daysMissed = 0
            }
            if playerStats.streak == 0 { // change to 7 on launch
                playerStats.level += 1
                if playerStats.level > playerStats.highestLevel {
                    playerStats.highestLevel = playerStats.level
                }
                gainedLevel = true
                playerStats.streak = 2 // change to 7 on launch
            }
        } else {
            playerStats.streak = 2 // change to 7 on launch
            playerStats.daysMissed += 1
            if playerStats.daysMissed >= 2 {
                if playerStats.level > 1 {
                    playerStats.level -= 1
                    lostLevel = true
                }
            }
        }
        
        UserDefaults.standard.set(playerStats.streak, forKey: "streak")
        UserDefaults.standard.set(playerStats.level, forKey: "level")
        UserDefaults.standard.set(playerStats.daysMissed, forKey: "daysMissed")
        UserDefaults.standard.set(playerStats.highestLevel, forKey: "highestLevel")
    }
    
    func checkLastLaunch() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        let lastLaunch = UserDefaults.standard.object(forKey: "lastLaunch") as? Date ?? Date()
        let lastLaunchDate = dateFormatter.string(from: lastLaunch)
        
        let today = Date()
        let todayDate = dateFormatter.string(from: today)
        
        print("lastLaunch: \(lastLaunch)")
        print("today: \(today)")
        print("lastLaunchDate: \(lastLaunchDate)")
        print("todayDate: \(todayDate)")
        
        if lastLaunchDate == todayDate { // change this back to != on launch
            var message: String
            var title = "Welcome back!"
            
            if playerStats.level == 1 {
                title = "Skeleton Quest"
            } else if playerStats.level == 2 {
                title = "Goblin Quest"
            } else if playerStats.level == 3 {
                title = "Witch Quest"
            } else if playerStats.level == 4 {
                title = "Vampire Quest"
            } else if playerStats.level == 5 {
                title = "Faceless Mage Quest"
            } else if playerStats.level == 6 {
                title = "Vampire Queen Quest"
            } else if playerStats.level == 7 {
                title = "Draconian Quest"
            } else if playerStats.level == 8 {
                title = "Ice Queen Quest"
            } else if playerStats.level == 9 {
                title = "Pyromancer Quest"
            } else if playerStats.level > 9 {
                title = "Necromancer Quest"
            }
            
            if gainedLevel == true {
                calculateRank()
                message = "You have vanquished the enemy - reaching Level \(playerStats.level) and the rank of \(UserDefaults.standard.object(forKey: "rank")!). There is no time to rest, however, as the \(title) has already begun! \n\n Days Until Victory: \(playerStats.streak) \n Days Missed: \(playerStats.daysMissed)"
            } else if dailiesDone == dailies.count {
                message = "Excellent! Yesterday you completed all of your Dailies. Keep it up, and you will actually complete the \(title) with your head intact! \n\n Days Until Victory: \(playerStats.streak) \n Days Missed: \(playerStats.daysMissed)"
            } else if lostLevel == true {
                message = "You have been defeated - returning to Level \(playerStats.level) and the rank of \(UserDefaults.standard.object(forKey: "rank")!). If you can't keep up, perhaps you should set a reminder, drop a Daily, or make it easier. \n\n Days Until Victory: \(playerStats.streak) \n Days Missed: \(playerStats.daysMissed)"
            } else {
                message = "Yesterday you completed \(dailiesDone) of your \(dailies.count) dailies. You must do better today or you will surely be defeated. \n\n Days Until Victory: \(playerStats.streak) \n Days Missed: \(playerStats.daysMissed)"
            }
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            let imageView = UIImageView(frame: CGRect(x: 0, y: -255, width: 270, height: 270))
            imageView.image = UIImage(named: "advisor")
            
            alert.view.addSubview(imageView)
            
            print("before debug warning")
            self.present(alert, animated: true, completion: nil)
            print("after debug warning")
            gainedLevel = false
        } else {
            print("You have already logged in today.")
        }
    }
    
    func calculateRank() {
        playerStats.level = UserDefaults.standard.object(forKey: "level") as! Int
        if playerStats.level == 1 {
            playerStats.rank = "Neophyte"
        } else if playerStats.level == 2 {
            playerStats.rank = "Apprentice"
        } else if playerStats.level == 3 {
            playerStats.rank = "Initiate"
        } else if playerStats.level == 4 {
            playerStats.rank = "Adept"
        } else if playerStats.level == 5 {
            playerStats.rank = "Mage"
        } else if playerStats.level == 6 {
            playerStats.rank = "Battle Mage"
        } else if playerStats.level == 7 {
            playerStats.rank = "Archmage"
        } else if playerStats.level == 8 {
            playerStats.rank = "Wizard"
        } else if playerStats.level == 9 {
            playerStats.rank = "Master Wizard"
        } else if playerStats.level > 9 {
            playerStats.rank = "Grandmaster Wizard"
        }
        UserDefaults.standard.set(playerStats.rank, forKey: "rank")
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
    
    // MARK: - Navigation
    // tells DailyDetailDailyVC that DailiesVC is its delegate
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddDaily" {
            let controller = segue.destination as! DailyDetailViewController
            
            controller.delegate = self 
        } else if segue.identifier == "EditDaily" {
            let controller = segue.destination as! DailyDetailViewController
            
            controller.delegate = self
            
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                controller.dailyToEdit = dailies[indexPath.row]
            }
        }
    }
}

