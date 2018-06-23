//
//  ViewController.swift
//  Dailies
//
//  Created by Banana Viking on 5/30/18.
//  Copyright © 2018 Banana Viking. All rights reserved.
//

import UIKit
import AVFoundation

class DailiesViewController: UITableViewController, DailyDetailViewControllerDelegate {
    
    var landscapeVC: LandscapeViewController?
    var audioPlayer: AVAudioPlayer?
    var player = QuestInfo()
    var dailies = [Daily]()
    var dailiesDone = 0
    var gainedLevel = false
    var lostLevel = false
    
    @IBAction func resetButton(_ sender: UIBarButtonItem) {
        resetGame()
    }
    
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
    
    // MARK: - function overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        player.quest = UserDefaults.standard.object(forKey: "quest") as? String ?? "Skeleton Quest"
        player.level = UserDefaults.standard.integer(forKey: "level")
        player.daysTil = UserDefaults.standard.integer(forKey: "daysTil")
        player.daysMissed = UserDefaults.standard.integer(forKey: "daysMissed")
        
        if player.level == 0 {  // need to make this better
            player.level = 1
        }
        
        loadDailies()
        checkDailiesComplete()
        checkLastLaunch()
        showNewDayMessage()
        calculateLevelInfo()
        resetDailies()
        
        self.tableView.isScrollEnabled = false // put this here because landscapeVC was scrolling up to DailiesVC without it
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
            playSound(forObject: "completeDaily")
        } else {
            label.text = ""
        }
    }
    
    func configureText(for cell: UITableViewCell, with daily: Daily) {
        let label = cell.viewWithTag(1000) as! UILabel
        label.text = daily.text
    }
    
    // gets full path to the Documents folder
    func documentsDirectory() -> URL {  // move to Data Models
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        return paths[0]
    }
    
    func dataFilePath() -> URL {  // move to Data Models
        return documentsDirectory().appendingPathComponent("Dailies.plist")
    }
    
    // takes contents of dailies array, converts to block of binary data, and writes it to a file
    func saveDailies() {  // move to Data Models
        let encoder = PropertyListEncoder()
        
        do {
            let data = try encoder.encode(dailies)
            
            try data.write(to: dataFilePath(), options: Data.WritingOptions.atomic)
        } catch {
            print("Error encoding daily array.")
        }
    }
    
    func loadDailies() {  // move to Data Models
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
        saveDailies()  // should this be pulled out of this function and just call it after resetDailies?
    }
    
    func checkDailiesComplete() {
        if dailies.count > 0 {
            if dailiesDone == dailies.count {
                if player.daysTil > 0 {
                    player.daysTil -= 1
                    player.daysMissed = 0
                }
                if player.daysTil == 0 { // change to 7 on launch
                    player.level += 1
                    gainedLevel = true
                    player.daysTil = 2 // change to 7 on launch
                }
            } else {
                player.daysTil = 2 // change to 7 on launch
                player.daysMissed += 1
                if player.daysMissed >= 2 {
                    if player.level > 1 {
                        player.level -= 1
                        lostLevel = true
                    }
                }
            }
        }
        
        UserDefaults.standard.set(player.level, forKey: "level")
        UserDefaults.standard.set(player.daysTil, forKey: "daysTil")
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
        
        if lastLaunchDate == todayDate { // change this back to != on launch
            player.isNewDay = true
        }
    }
    
    func showNewDayMessage() {
        if player.isNewDay == true {
            let title = player.quest
            let messageTitle = title + " Update"
            var message: String
            let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 246, height: 246)))
            
            calculateLevelInfo()
            
            if gainedLevel == true {
                imageView.image = UIImage(named: "advisor0")
                message = "Advisor: \"Victory! You have vanquished the enemy - reaching Level \(player.level) and the rank of \(UserDefaults.standard.object(forKey: "rank")!). There is no time to rest, however, as the \(player.quest) has already begun!\" \n\n Days Until Victory: \(player.daysTil) \n Days Missed: \(player.daysMissed)"
                playSound(forObject: "gainLevel")
            } else if dailies.count == 0 {
                imageView.image = UIImage(named: "advisor0")
                message = "Advisor: \"Add some Dailies when you are ready to begin your quest. But be warned, you have a much better chance of surviving if you start small and build on consistent wins.\""
            } else if dailiesDone == dailies.count {
                imageView.image = UIImage(named: "advisor0")
                message = "Advisor: \"Well done! Yesterday you completed all of your Dailies. Keep it up and you will actually complete the \(title) with your head intact!\" \n\n Days Until Victory: \(player.daysTil) \n Days Missed: \(player.daysMissed)"
                playSound(forObject: "completeDailies")
            } else if lostLevel == true {
                imageView.image = UIImage(named: "advisor1")
                message = "Advisor: \"You have been defeated - returning to Level \(player.level) and the rank of \(UserDefaults.standard.object(forKey: "rank")!). If you can't keep up, perhaps you should set a reminder, drop a Daily, or make it easier.\" \n\n Days Until Victory: \(player.daysTil) \n Days Missed: \(player.daysMissed)"
                playSound(forObject: "loseLevel")
            } else {
                imageView.image = UIImage(named: "advisor1")
                message = "Advisor: \"Yesterday you completed \(dailiesDone) of your \(dailies.count) dailies. You must do better today or you will surely be defeated.\" \n\n Days Until Victory: \(player.daysTil) \n Days Missed: \(player.daysMissed)"
                playSound(forObject: "missDailies")
            }
            
            UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, imageView.isOpaque, 0.0)
            defer { UIGraphicsEndImageContext() }
            let context = UIGraphicsGetCurrentContext()
            imageView.layer.render(in: context!)
            let finalImage = UIGraphicsGetImageFromCurrentImageContext()
            
            let alert = UIAlertController(title: messageTitle, message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: "", style: .default, handler: nil)
            action.setValue(finalImage?.withRenderingMode(UIImageRenderingMode.alwaysOriginal), forKey: "image")
            alert .addAction(action)
            let action1 = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert .addAction(action1)
            self.present(alert, animated: true, completion: nil)  // giving compiler warning because adding an image view to a detached alert view?
            
            gainedLevel = false
            player.isNewDay = false  // need this?
        }
    }
    
    func calculateLevelInfo() {
        player.level = UserDefaults.standard.integer(forKey: "level")
        let playerImageView = self.view.viewWithTag(600) as! UIImageView
        
        if player.level == 1 {
            player.rank = "Neophyte"
            player.quest = "Skeleton Quest"
            playerImageView.image = UIImage(named: "wizard1")
        } else if player.level == 2 {
            player.rank = "Apprentice"
            player.quest = "Goblin Quest"
            playerImageView.image = UIImage(named: "wizard2")
        } else if player.level == 3 {
            player.rank = "Initiate"
            player.quest = "Witch Quest"
            playerImageView.image = UIImage(named: "wizard3")
        } else if player.level == 4 {
            player.rank = "Adept"
            player.quest = "Vampire Quest"
            playerImageView.image = UIImage(named: "wizard4")
        } else if player.level == 5 {
            player.rank = "Mage"
            player.quest = "Faceless Mage Quest"
            playerImageView.image = UIImage(named: "wizard5")
        } else if player.level == 6 {
            player.rank = "Battle Mage"
            player.quest = "Vampire Queen Quest"
            playerImageView.image = UIImage(named: "wizard6")
        } else if player.level == 7 {
            player.rank = "Archmage"
            player.quest = "Draconian Quest"
            playerImageView.image = UIImage(named: "wizard7")
        } else if player.level == 8 {
            player.rank = "Wizard"
            player.quest = "Ice Queen Quest"
            playerImageView.image = UIImage(named: "wizard8")
        } else if player.level == 9 {
            player.rank = "Master Wizard"
            player.quest = "Pyromancer Quest"
            playerImageView.image = UIImage(named: "wizard9")
        } else if player.level >= 10 {
            player.rank = "Grandmaster Wizard"
            player.quest = "Necromancer Quest"
            playerImageView.image = UIImage(named: "wizard10")
        }
        UserDefaults.standard.set(player.rank, forKey: "rank")
        UserDefaults.standard.set(player.quest, forKey: "quest")
    }
    
    func resetGame() {
        let alert = UIAlertController(title: "Are you sure you want to reset the game?", message: "This will remove all of your Dailies and Quest Info.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.playSound(forObject: "resetGame")
            self.resetDailies()
            UserDefaults.standard.set(1, forKey: "level")
            UserDefaults.standard.set(2, forKey: "daysTil")  // change to 7 on launch
            UserDefaults.standard.set(0, forKey: "daysMissed")
            self.calculateLevelInfo()
            self.dailies.removeAll()
            self.saveDailies()
            self.tableView.reloadData()
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    func playSound(forObject: String) {
        guard let url = Bundle.main.url(forResource: forObject, withExtension: "wav") else {
            print("url not found")
            return
        }
        
        do {
            /// this codes for making this app ready to takeover the device audio
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.wav.rawValue)
            
            audioPlayer!.play()
        } catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }
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
        playSound(forObject: "rotate")
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
        playSound(forObject: "rotate")
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

