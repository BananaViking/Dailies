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
    var player = QuestInfo()
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
        
        player.quest = UserDefaults.standard.object(forKey: "quest") as? String ?? "Skeleton Quest"
        player.level = UserDefaults.standard.integer(forKey: "level")
        player.streak = UserDefaults.standard.integer(forKey: "streak")
        player.daysMissed = UserDefaults.standard.integer(forKey: "daysMissed")
        
        if player.level == 0 {
            player.level = 1
        }
        
        loadDailies()
        checkDailiesComplete()
        checkLastLaunch()
        calculateLevelInfo()
        resetDailies()

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
            if player.streak > 0 {
            player.streak -= 1
            player.daysMissed = 0
            }
            if player.streak == 0 { // change to 7 on launch
                player.level += 1
                gainedLevel = true
                player.streak = 2 // change to 7 on launch
            }
        } else {
            player.streak = 2 // change to 7 on launch
            player.daysMissed += 1
            if player.daysMissed >= 2 {
                if player.level > 1 {
                    player.level -= 1
                    lostLevel = true
                }
            }
        }
        
        UserDefaults.standard.set(player.streak, forKey: "streak")
        UserDefaults.standard.set(player.level, forKey: "level")
        UserDefaults.standard.set(player.daysMissed, forKey: "daysMissed")
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
            let title = player.quest
            calculateLevelInfo()

            if gainedLevel == true {
                message = "You have vanquished the enemy - reaching Level \(player.level) and the rank of \(UserDefaults.standard.object(forKey: "rank")!). There is no time to rest, however, as the \(player.quest) has already begun! \n\n Days Until Victory: \(player.streak) \n Days Missed: \(player.daysMissed)"
            } else if dailiesDone == dailies.count {
                message = "Excellent! Yesterday you completed all of your Dailies. Keep it up and you will actually complete the \(title) with your head intact! \n\n Days Until Victory: \(player.streak) \n Days Missed: \(player.daysMissed)"
            } else if lostLevel == true {
                message = "You have been defeated - returning to Level \(player.level) and the rank of \(UserDefaults.standard.object(forKey: "rank")!). If you can't keep up, perhaps you should set a reminder, drop a Daily, or make it easier. \n\n Days Until Victory: \(player.streak) \n Days Missed: \(player.daysMissed)"
            } else {
                message = "Yesterday you completed \(dailiesDone) of your \(dailies.count) dailies. You must do better today or you will surely be defeated. \n\n Days Until Victory: \(player.streak) \n Days Missed: \(player.daysMissed)"
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
    
    func calculateLevelInfo() {
        player.level = UserDefaults.standard.integer(forKey: "level")
        let wizardImage = self.view.viewWithTag(600) as! UIImageView

        if player.level == 1 {
            player.rank = "Neophyte"
            player.quest = "Skeleton Quest"
            wizardImage.image = UIImage(named: "wizard1")
        } else if player.level == 2 {
            player.rank = "Apprentice"
            player.quest = "Goblin Quest"
            wizardImage.image = UIImage(named: "wizard2")
        } else if player.level == 3 {
            player.rank = "Initiate"
            player.quest = "Witch Quest"
            wizardImage.image = UIImage(named: "wizard3")
        } else if player.level == 4 {
            player.rank = "Adept"
            player.quest = "Vampire Quest"
            wizardImage.image = UIImage(named: "wizard4")
        } else if player.level == 5 {
            player.rank = "Mage"
            player.quest = "Faceless Mage Quest"
            wizardImage.image = UIImage(named: "wizard5")
        } else if player.level == 6 {
            player.rank = "Battle Mage"
            player.quest = "Vampire Queen Quest"
            wizardImage.image = UIImage(named: "wizard6")
        } else if player.level == 7 {
            player.rank = "Archmage"
            player.quest = "Draconian Quest"
            wizardImage.image = UIImage(named: "wizard7")
        } else if player.level == 8 {
            player.rank = "Wizard"
            player.quest = "Ice Queen Quest"
            wizardImage.image = UIImage(named: "wizard8")
        } else if player.level == 9 {
            player.rank = "Master Wizard"
            player.quest = "Pyromancer Quest"
            wizardImage.image = UIImage(named: "wizard9")
        } else if player.level >= 10 {
            player.rank = "Grandmaster Wizard"
            player.quest = "Necromancer Quest"
            wizardImage.image = UIImage(named: "wizard10")
        }
        UserDefaults.standard.set(player.rank, forKey: "rank")
        UserDefaults.standard.set(player.quest, forKey: "quest")
        navigationItem.title = player.quest
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

