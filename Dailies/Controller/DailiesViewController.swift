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
    var playerInfo = PlayerInfo()
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
                playerInfo.dailiesDone += 1
            } else if playerInfo.dailiesDone > 0 {  // need the dailiesDone > 0 here?
                // playSound(forObject: "uncheckDaily")  // add this back if want the noise
                playerInfo.dailiesDone -= 1
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
        saveDailies()
    }
    
    // enables swipe to delete rows
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCellEditingStyle,
                            forRowAt indexPath: IndexPath) {
        let daily = dailies[indexPath.row]
        if daily.checked {
            if playerInfo.dailiesDone > 0 {
                playerInfo.dailiesDone -= 1
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
    
    // MARK: - Function Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground),
                                               name: .UIApplicationWillEnterForeground,
                                               object: nil)
        playerInfo.level = UserDefaults.standard.integer(forKey: "level")
        playerInfo.daysTil = UserDefaults.standard.integer(forKey: "daysTil")
        playerInfo.daysMissed = UserDefaults.standard.integer(forKey: "daysMissed")
    
        setupFirstLaunch()
        loadDailies()
        checkLastLaunch()
        playerInfo.calculateLevelInfo()
        updatePlayerImage()
        
        if playerInfo.isNewDay == true {
            countCheckedDailies()
            processDay()
            playerInfo.calculateLevelInfo()
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
            playerInfo.daysMissed = UserDefaults.standard.integer(forKey: "daysMissed")
            playerInfo.calculateLevelInfo()
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
    
    // MARK: - Functions
    @objc func willEnterForeground() {
        setupFirstLaunch()
        checkLastLaunch()
        
        if playerInfo.isNewDay == true {
            processDay()
            playerInfo.calculateLevelInfo()
            updatePlayerImage()
            showNewDayMessage()
            resetDailies()
            saveDailies()
            tableView.reloadData()
        }
    }
    
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
    func getDocumentsDirectory() -> URL {  // move to Data Models?
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func getDataFilePath() -> URL {  // move to Data Models?
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
    
    func loadDailies() {  // move to Data Models?
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
        parent?.present(messageViewController, animated: true, completion: nil)
    }
    
    func setupFirstLaunch() {
        playerInfo.launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if playerInfo.launchedBefore == false {
            UserDefaults.standard.set(true, forKey: "launchedBefore")
            if playerInfo.level == 0 {
                UserDefaults.standard.set(1, forKey: "level")
                playerInfo.daysTil = 3  // change to 7 in launch
            }
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let pageViewController = storyBoard.instantiateViewController(withIdentifier: "pageViewController")
            pageViewController.modalTransitionStyle = .crossDissolve
            parent?.present(pageViewController, animated: true, completion: nil)
            playSound(forObject: "firstLaunch")
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
            playerInfo.isNewDay = true
        } else {
            playerInfo.isNewDay = false
        }
    }
    
    func countCheckedDailies() {
        for daily in dailies where daily.checked {
            playerInfo.dailiesDone += 1
        }
    }
    
    func processDay() {  
        if playerInfo.dailiesDone == dailies.count && dailies.count > 0 {
            playerInfo.perfectDay = true
        } else {
            playerInfo.perfectDay = false
        }
        
        switch playerInfo.perfectDay {
        case true where playerInfo.daysTil > 1:
            playerInfo.daysTil -= 1
            playerInfo.daysMissed = 0
        case true where playerInfo.daysTil == 1:
            playerInfo.level += 1
            if playerInfo.level == 11 {
                UserDefaults.standard.set(true, forKey: "beatGame")
            }
            playerInfo.gainedLevel = true
            playerInfo.daysTil = 3 // change to 7 on launch
        case false where dailies.count == 0:
            print("dailies.count: \(dailies.count)")
        case false:
            playerInfo.daysMissed += 1
            playerInfo.daysTil = 3 // change to 7 on launch
            if playerInfo.daysMissed >= 2 && playerInfo.level > 0 {
                playerInfo.level -= 1
                if playerInfo.level == 0 {
                    UserDefaults.standard.set(true, forKey: "lostGame")
                }
                playerInfo.lostLevel = true
            }
        default:
            print("Error processing day")
        }
        UserDefaults.standard.set(playerInfo.level, forKey: "level")
        UserDefaults.standard.set(playerInfo.daysTil, forKey: "daysTil")
        UserDefaults.standard.set(playerInfo.daysMissed, forKey: "daysMissed")
    }
    
    func updatePlayerImage() {
        if let playerImageView = view.viewWithTag(600) as? UIImageView {
            playerImageView.layer.cornerRadius = 8
            playerImageView.image = UIImage(named: playerInfo.playerImage)
        }
    }
    
    func showNewDayMessage() {
        if dailies.count == 0 {
            UserDefaults.standard.set(true, forKey: "noDailies")
        } else if playerInfo.gainedLevel == true {
            UserDefaults.standard.set(true, forKey: "gainLevel")
        } else if playerInfo.perfectDay == true {
            UserDefaults.standard.set(true, forKey: "completeDailies")
        } else if playerInfo.lostLevel == true {
            UserDefaults.standard.set(true, forKey: "loseLevel")
        } else if playerInfo.perfectDay == false {
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
        
        playerInfo.dailiesDone = 0
        playerInfo.gainedLevel = false  // still need this now with UserDefault resets at end of showNewDayMessage?
        playerInfo.lostLevel = false  // need lostLevel to stay true until decrement and correct message is shown, then it needs to be reset for next day? // still need this now with UserDefault resets at end of showNewDayMessage?
    }
    
    func resetGame() {
        let alert = UIAlertController(title: "Are you sure you want to reset the game?",
                                      message: "This will remove all of your Dailies and Quest Info.",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.playSound(forObject: "resetGame")
            self.resetDailies()
            UserDefaults.standard.set(1, forKey: "level")
            UserDefaults.standard.set(3, forKey: "daysTil")  // change to 7 on launch
            UserDefaults.standard.set(0, forKey: "daysMissed")
            self.playerInfo.calculateLevelInfo()
            self.updatePlayerImage()
            self.dailies.removeAll()
            UserDefaults.standard.set(true, forKey: "noDailies")
            self.saveDailies()
            self.tableView.reloadData()
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    func playSound(forObject: String) {
        guard let url = Bundle.main.url(forResource: forObject, withExtension: "wav") else { return }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            guard let audioPlayer = audioPlayer else { return }
            audioPlayer.prepareToPlay()
            audioPlayer.play()
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
//        guard landscapeVC == nil else { return }
        landscapeVC = storyboard?.instantiateViewController(withIdentifier: "LandscapeViewController") as? LandscapeViewController //changed storyboard! to ? and commented out above line
        
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
            navigationController?.isNavigationBarHidden = true
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

