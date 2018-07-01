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
    var dailiesDone = 0
    var perfectDay = false
    var gainedLevel = false
    var lostLevel = false
    var launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
    
    @IBAction func resetButton(_ sender: UIBarButtonItem) {
        resetGame()
    }
    
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
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
    
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // MARK: - function overrides
    // my selector that was defined above
    @objc func willEnterForeground() {
        print("willEnterForeground called")
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
        print("appEnteredForeground")
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
        let isFreshWin = UserDefaults.standard.bool(forKey: "isFreshWin")
        if isFreshWin == true {
            resetDailies()
            player.calculateLevelInfo()
            updatePlayerImage()
            dailies.removeAll()
            saveDailies()
            tableView.reloadData()
            UserDefaults.standard.set(false, forKey: "isFreshWin")
        }
    }
    
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
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
                dailiesDone += 1
                print("\(dailiesDone) out of \(dailies.count) completed.")
            } else if dailiesDone > 0 {  // need the dailiesDone > 0 here?
//                playSound(forObject: "uncheckDaily")  // add this back if want the noise
                dailiesDone -= 1
                print("\(dailiesDone) out of \(dailies.count) completed.")
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
        playSound(forObject: "deleteDaily")
        saveDailies()
    }
    
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
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
        print("savedDailies")
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
        print("loadedDailies")
    }
    
    func setupFirstLaunch() {
        launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        print("launched before: \(launchedBefore)")
        if launchedBefore == false {
            if player.level == 0 {
                player.level = 1
                player.daysTil = 2
            }
            
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let MessageViewController = storyBoard.instantiateViewController(withIdentifier: "messageViewController")
            self.present(MessageViewController, animated: true, completion: nil)
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
        print("checkedLastLaunch")
    }
    
    func countCheckedDailies() {
        for daily in dailies where daily.checked {
            dailiesDone += 1
        }
        print("countedCheckedDailies")
    }
    
    func processDay() {  // refactor this to get away from all the nested ifs. too hard to understand at a glance.
        if dailiesDone == dailies.count && dailies.count > 0 {
            perfectDay = true
        } else {
            perfectDay = false
        }
        
        switch perfectDay {
        case true where player.daysTil > 1:
            player.daysTil -= 1
            player.daysMissed = 0
        case true where player.daysTil == 1:
            player.level += 1
            if player.level == 11 {
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let MessageViewController = storyBoard.instantiateViewController(withIdentifier: "messageViewController")
                self.present(MessageViewController, animated: true, completion: nil)
            }
            gainedLevel = true
            player.daysTil = 2 // change to 7 on launch
        case false where dailies.count == 0:
            print("no dailies")
        case false:
            player.daysMissed += 1
            player.daysTil = 2 // change to 7 on launch
            if player.daysMissed >= 2 && player.level > 1 {
                player.level -= 1
                lostLevel = true
            }
        default:
            print("Error processing day")
        }
        UserDefaults.standard.set(player.level, forKey: "level")
        UserDefaults.standard.set(player.daysTil, forKey: "daysTil")
        UserDefaults.standard.set(player.daysMissed, forKey: "daysMissed")
        
        print("processedDay")
    }
    
    func updatePlayerImage() {
        if let playerImageView = self.view.viewWithTag(600) as? UIImageView {
            playerImageView.layer.cornerRadius = 8
            playerImageView.image = UIImage(named: player.playerImage)
        }
        
        print("updatedPlayerImage")
    }
    
    func showNewDayMessage() {
        let title = player.quest
        var messageTitle = title + " Update"
        var message = ""
        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 246, height: 246)))
        
        if launchedBefore == false {
            imageView.image = UIImage(named: "advisorHappy")
            messageTitle = "A New Beginning"
            message = "Maya: \"Welcome to Habit Quest! My name is Maya, and I will be your advisor on your journey. Add some Dailies when you are ready to begin the Skeleton Quest. But be warned, you have a much better chance of surviving if you start small and build on consistent wins. Good luck!\""
            playSound(forObject: "firstLaunch")
        } else if dailies.count == 0 {
            imageView.image = UIImage(named: "advisorMad")
            message = "Maya: \"You must add at least one Daily before returning to your quest. Hurry up before it's too late!\""
            playSound(forObject: "noDailies")
        } else if gainedLevel == true {  // rewrite this as switch statement
            imageView.image = UIImage(named: "advisorHappy")
            message = "Maya: \"Victory! You have vanquished the enemy - reaching Level \(player.level) and the rank of \(UserDefaults.standard.object(forKey: "rank")!). There is no time to rest, however, as the \(player.quest) has already begun!\" \n\n Days Until Victory: \(player.daysTil) \n Days Missed: \(player.daysMissed)"
            playSound(forObject: "gainLevel")
        } else if perfectDay == true {
            imageView.image = UIImage(named: "advisorHappy")
            message = "Maya: \"Well done! Yesterday you completed all of your Dailies. Keep it up and you will actually complete the \(title) with your head intact!\" \n\n Days Until Victory: \(player.daysTil) \n Days Missed: \(player.daysMissed)"
            playSound(forObject: "completeDailies")
        } else if lostLevel == true {
            imageView.image = UIImage(named: "advisorMad")
            message = "Maya: \"You have been defeated - returning to Level \(player.level) and the rank of \(UserDefaults.standard.object(forKey: "rank")!). If you can't keep up, perhaps you should set a reminder, drop a Daily, or make it easier.\" \n\n Days Until Victory: \(player.daysTil) \n Days Missed: \(player.daysMissed)"
            playSound(forObject: "loseLevel")
        } else if perfectDay == false {
            imageView.image = UIImage(named: "advisorMad")
            message = "Maya: \"Yesterday you completed \(dailiesDone) of your \(dailies.count) dailies. You must do better today or you will surely be defeated.\" \n\n Days Until Victory: \(player.daysTil) \n Days Missed: \(player.daysMissed)"
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
        
        print("showedNewDayMessage")
    }
    
    func resetDailies() {
        for daily in dailies {
            daily.checked = false
        }
        
        dailiesDone = 0
        gainedLevel = false
        lostLevel = false  // need lostLevel to stay true until decrement and correct message is shown, then it needs to be reset for next day?
        
        print("resetDailies")
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
            self.saveDailies()
            self.tableView.reloadData()
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(alert, animated: true)
        
        print("resetGame")
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
    
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
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
    
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
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

