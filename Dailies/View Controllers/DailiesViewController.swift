//
//  DailiesViewController.swift
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
        playSound(forObject: "addDaily")
        UserDefaults.standard.set(false, forKey: "noDailies")
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
    // my selector that was defined above
    @objc func willEnterForeground() {
        setupFirstLaunch()
        checkLastLaunch()
        
        if player.isNewDay == true {
            processDay()
            player.calculateLevelInfo()
            updatePlayerImage()
            showNewDayMessage()
            resetDailies()
            saveDailies()
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
        
        player.level = UserDefaults.standard.integer(forKey: "level")
        player.daysTil = UserDefaults.standard.integer(forKey: "daysTil")
        player.daysMissed = UserDefaults.standard.integer(forKey: "daysMissed")
        
        setupFirstLaunch()
        loadDailies()
        checkLastLaunch()
        player.calculateLevelInfo()
        updatePlayerImage()
        
        if player.isNewDay == true {
            countCheckedDailies()
            processDay()
            player.calculateLevelInfo()
            updatePlayerImage()
            showNewDayMessage()
            resetDailies()
            saveDailies()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {  // to update the image after winning the game and resetting
        let beatGame = UserDefaults.standard.bool(forKey: "beatGame")
        let lostGame = UserDefaults.standard.bool(forKey: "lostGame")
        
        if beatGame == true || lostGame == true {
            UserDefaults.standard.set(1, forKey: "level")
            UserDefaults.standard.set(0, forKey: "daysMissed")
            player.daysMissed = UserDefaults.standard.integer(forKey: "daysMissed")
            player.calculateLevelInfo()
            updatePlayerImage()
            resetDailies()
            dailies.removeAll()
            saveDailies()
            tableView.reloadData()
            UserDefaults.standard.set(false, forKey: "beatGame")
            UserDefaults.standard.set(false, forKey: "lostGame")
            playSound(forObject: "resetGame")
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
                playSound(forObject: "completeDaily")
                player.dailiesDone += 1
            } else if player.dailiesDone > 0 {  // need the dailiesDone > 0 here?
//                playSound(forObject: "uncheckDaily")  // add this back if want the noise
                player.dailiesDone -= 1
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        saveDailies()
    }
    
    // enables swipe to delete rows
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        let daily = dailies[indexPath.row]
        if daily.checked {
            if player.dailiesDone > 0 {
                player.dailiesDone -= 1
            }
        }
        dailies.remove(at: indexPath.row)
        
        if dailies.count == 0 {
            UserDefaults.standard.set(true, forKey: "noDailies")
        }
        
        let indexPaths = [indexPath]
        tableView.deleteRows(at: indexPaths, with: .automatic)
        playSound(forObject: "deleteDaily")
        saveDailies()
    }
    
    
    // MARK: - Functions
    func configureCheckmark(for cell: UITableViewCell, with daily: Daily) {
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
    func getDocumentsDirectory() -> URL {  // move to Data Models
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func getDataFilePath() -> URL {  // move to Data Models
        return getDocumentsDirectory().appendingPathComponent("Dailies.plist")
    }
    
    // takes contents of dailies array, converts to block of binary data, and writes it to a file
    func saveDailies() {  // move to Data Models? does this only need to be called when app exits?
        let encoder = PropertyListEncoder()
        
        do {
            let data = try encoder.encode(dailies)
            
            try data.write(to: getDataFilePath(), options: Data.WritingOptions.atomic)
        } catch {
            print("Error encoding daily array.")
        }
    }
    
    func loadDailies() {  // move to Data Models
        let path = getDataFilePath()
        
        if let data = try? Data(contentsOf: path) {
            let decoder = PropertyListDecoder()
            
            do {
                dailies = try decoder.decode([Daily].self, from: data)
            } catch {
                print("Error decoding daily array.")
            }
        }
    }
    
    func presentMessageVC() {  // getting the unbalanced calls error in llvm because we are doing modal messageVC presentation in viewDidLoad instead of viewDidAppear
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let messageViewController = storyBoard.instantiateViewController(withIdentifier: "messageViewController")
        messageViewController.modalTransitionStyle = .crossDissolve
        self.parent?.present(messageViewController, animated: true, completion: nil)
    }
    
    func setupFirstLaunch() {
        player.launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if player.launchedBefore == false {
            if player.level == 0 {
                UserDefaults.standard.set(1, forKey: "level")
                player.daysTil = 2  // changed to 7 in launch
            }
        }
    }
    
    func checkLastLaunch() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd"

        let lastLaunch = UserDefaults.standard.object(forKey: "lastLaunch") as? Date ?? Date()
        let lastLaunchDate = dateFormatter.string(from: lastLaunch)
        let today = Date()
        let todayDate = dateFormatter.string(from: today)
        
        if lastLaunchDate == todayDate { // change this back to != on launch
            player.isNewDay = true
        } else {
            player.isNewDay = false
        }
    }
    
    func countCheckedDailies() {
        for daily in dailies where daily.checked {
            player.dailiesDone += 1
        }
    }
    
    func processDay() {  
        if player.dailiesDone == dailies.count && dailies.count > 0 {
            player.perfectDay = true
        } else {
            player.perfectDay = false
        }
        
        switch player.perfectDay {
        case true where player.daysTil > 1:
            player.daysTil -= 1
            player.daysMissed = 0
        case true where player.daysTil == 1:
            player.level += 1
            if player.level == 11 {
                UserDefaults.standard.set(true, forKey: "beatGame")
            }
            player.gainedLevel = true
            player.daysTil = 2 // change to 7 on launch
        case false where dailies.count == 0:
            print("dailies.count: \(dailies.count)")
        case false:
            player.daysMissed += 1
            player.daysTil = 2 // change to 7 on launch
            if player.daysMissed >= 2 && player.level > 0 {
                player.level -= 1
                if player.level == 0 {
                    UserDefaults.standard.set(true, forKey: "lostGame")
                }
                player.lostLevel = true
            }
        default:
            print("Error processing day")
        }
        UserDefaults.standard.set(player.level, forKey: "level")
        UserDefaults.standard.set(player.daysTil, forKey: "daysTil")
        UserDefaults.standard.set(player.daysMissed, forKey: "daysMissed")
    }
    
    func updatePlayerImage() {
        if let playerImageView = self.view.viewWithTag(600) as? UIImageView {
            playerImageView.layer.cornerRadius = 8
            playerImageView.image = UIImage(named: player.playerImage)
        }
    }
    
    func showNewDayMessage() {
        if dailies.count == 0 {
            UserDefaults.standard.set(true, forKey: "noDailies")
        } else if player.gainedLevel == true {
            UserDefaults.standard.set(true, forKey: "gainLevel")
        } else if player.perfectDay == true {
            UserDefaults.standard.set(true, forKey: "completeDailies")
        } else if player.lostLevel == true {
            UserDefaults.standard.set(true, forKey: "loseLevel")
        } else if player.perfectDay == false {
            UserDefaults.standard.set(true, forKey: "missDailies")
        }
        
        presentMessageVC()
        
        UserDefaults.standard.set(false, forKey: "gainLevel")
        UserDefaults.standard.set(false, forKey: "completeDailies")
        UserDefaults.standard.set(false, forKey: "loseLevel")
        UserDefaults.standard.set(false, forKey: "missDailies")
    }
    
    func resetDailies() {
        for daily in dailies {
            daily.checked = false
        }
        
        player.dailiesDone = 0
        player.gainedLevel = false  // still need this now with UserDefault resets at end of showNewDayMessage?
        player.lostLevel = false  // need lostLevel to stay true until decrement and correct message is shown, then it needs to be reset for next day? // still need this now with UserDefault resets at end of showNewDayMessage?
    }
    
    func resetGame() {
        let alert = UIAlertController(title: "Are you sure you want to reset the game?", message: "This will remove all of your Dailies and Quest Info.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.playSound(forObject: "resetGame")
            self.resetDailies()
            UserDefaults.standard.set(1, forKey: "level")
            UserDefaults.standard.set(2, forKey: "daysTil")  // change to 7 on launch
            UserDefaults.standard.set(0, forKey: "daysMissed")
            self.player.calculateLevelInfo()
            self.updatePlayerImage()
            self.dailies.removeAll()
            UserDefaults.standard.set(true, forKey: "noDailies")
            self.saveDailies()
            self.tableView.reloadData()
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    func playSound(forObject: String) {
        guard let url = Bundle.main.url(forResource: forObject, withExtension: "wav") else { return }
        
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

