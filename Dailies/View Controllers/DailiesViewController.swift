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
    var daysGone = 0
    
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
        print("willEnterForeground called: dailiesDone: \(dailiesDone) of \(dailies.count), daysMissed: \(player.daysMissed), lostLevel: \(lostLevel), gainedLevel: \(gainedLevel)")

        checkLastLaunch()
        
        if player.isNewDay == true {
//            loadDailies()  // don't need to load them if they're already loaded right?
//            countCheckedDailies()
            processCheckedDailies()
            player.calculateLevelInfo()
            updatePlayerImage()
            showNewDayMessage()
            resetDailies()
            saveDailies()
            
            self.tableView.reloadData()
        }
        print("appEnteredForeground: dailiesDone: \(dailiesDone) of \(dailies.count), daysMissed: \(player.daysMissed), lostLevel: \(lostLevel), gainedLevel: \(gainedLevel)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
        
        // settings these properties to UD in viewDidLoad will overwrite the initial values, need to create a setupFirstLaunch() function to handle initial values and game introduction/instructions
        player.level = UserDefaults.standard.integer(forKey: "level")
        player.daysTil = UserDefaults.standard.integer(forKey: "daysTil")  // newly added
        player.daysMissed = UserDefaults.standard.integer(forKey: "daysMissed")
        
        if player.level == 0 {  // need to add setupFirstLaunch() (runFirstLaunch?) and get rid of this
            player.level = 1
            player.daysTil = 2
        }
        
        loadDailies()
        checkLastLaunch()
        
        if player.isNewDay == true {
            countCheckedDailies()
            processCheckedDailies()
            player.calculateLevelInfo()
            updatePlayerImage()
            showNewDayMessage()
            resetDailies()
            saveDailies()
        }
            
        tableView.isScrollEnabled = false // landscapeVC was scrolling up showing DailiesVC underneath without it
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
    
    
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
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
        print("savedDailies: dailiesDone: \(dailiesDone) of \(dailies.count), daysMissed: \(player.daysMissed), lostLevel: \(lostLevel), gainedLevel: \(gainedLevel)")
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
        
        print("loadedDailies: dailiesDone: \(dailiesDone) of \(dailies.count), daysMissed: \(player.daysMissed), lostLevel: \(lostLevel), gainedLevel: \(gainedLevel)")
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
        }
        
        daysGone = Calendar.current.dateComponents([.day], from: lastLaunch, to: today).day ?? 0
        
        // code below was looping through making you lose more and more levels than supposed to the more days you missed
//        if daysGone > 1 {
//            player.daysMissed += daysGone - 1 // need to put a minus 1 here or somewhere? gives -1 if 0 daysGone so added surrounding if clause
//        }
//
//        if player.daysMissed >= 2 {
//            for _ in 1..<player.daysMissed {  // ..< because you don't lose a level for first day Missed
//                if player.level > 1 {
//                    player.level -= 1
//                    lostLevel = true
//                    print("level lost from checkLastLaunch. level: \(player.level)")
//                }
//            }
//        }
        
        UserDefaults.standard.set(player.level, forKey: "level")
        UserDefaults.standard.set(player.daysMissed, forKey: "daysMissed")
        
        print("lastLaunchDate: \(lastLaunchDate) \ntodayDate: \(todayDate) \nisNewDay: \(player.isNewDay) \ndaysGone: \(daysGone) \ndaysMissed: \(player.daysMissed)")
        print("checkedLastLaunch: dailiesDone: \(dailiesDone) of \(dailies.count), daysMissed: \(player.daysMissed), lostLevel: \(lostLevel), gainedLevel: \(gainedLevel)")
        
    }
    
    func countCheckedDailies() {
        for daily in dailies where daily.checked {
            dailiesDone += 1
        }
        
        print("countedCheckedDailies: dailiesDone: \(dailiesDone) of \(dailies.count), daysMissed: \(player.daysMissed), lostLevel: \(lostLevel), gainedLevel: \(gainedLevel)")
    }
    
    func processCheckedDailies() {  // refactor this to get away from all the nested ifs. too hard to understand at a glance.
        
        print("processCheckedDailies called: dailiesDone: \(dailiesDone) of \(dailies.count), daysMissed: \(player.daysMissed), lostLevel: \(lostLevel), gainedLevel: \(gainedLevel)")
        
        if dailies.count > 0 {  // solve this a different way?
            if dailiesDone == dailies.count && player.daysTil > 1 {  // refactored this and changed daysTil > 0 to > 1
                player.daysTil -= 1
                player.daysMissed = 0
            } else if dailiesDone == dailies.count && player.daysTil == 1 { // change to 7 on launch, refactored this and changed daysTil == 0 to == 1
                player.level += 1
                gainedLevel = true
                player.daysTil = 2 // change to 7 on launch
                print("gained level")
            } else if dailiesDone != dailies.count { // this is bad because only using it for one specific case, but else catches anything else
                player.daysMissed += 1
                player.daysTil = 2 // change to 7 on launch
                if player.daysMissed >= 2 && player.level > 1 {
                    player.level -= 1
                    lostLevel = true
                    print("level lost from countCheckedDailies. level: \(player.level)")
                }
            }
        }
        
        UserDefaults.standard.set(player.level, forKey: "level")
        UserDefaults.standard.set(player.daysTil, forKey: "daysTil")
        UserDefaults.standard.set(player.daysMissed, forKey: "daysMissed")
        
        print("processedCheckedDailies: dailiesDone: \(dailiesDone) of \(dailies.count), daysMissed: \(player.daysMissed), lostLevel: \(lostLevel), gainedLevel: \(gainedLevel)")
    }
    
    func updatePlayerImage() {
        let playerImageView = self.view.viewWithTag(600) as! UIImageView
        playerImageView.image = UIImage(named: player.playerImage)
        
        print("updatedPlayerImage")
    }
    
    func showNewDayMessage() {
        
        print("showNewDayMessage called: dailiesDone: \(dailiesDone) of \(dailies.count), daysMissed: \(player.daysMissed), lostLevel: \(lostLevel), gainedLevel: \(gainedLevel)")
        
        let title = player.quest
        let messageTitle = title + " Update"
        var message: String
        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 246, height: 246)))
        
        if gainedLevel == true {  // rewrite this as switch statement
            imageView.image = UIImage(named: "advisorHappy")
            message = "Advisor: \"Victory! You have vanquished the enemy - reaching Level \(player.level) and the rank of \(UserDefaults.standard.object(forKey: "rank")!). There is no time to rest, however, as the \(player.quest) has already begun!\" \n\n Days Until Victory: \(player.daysTil) \n Days Missed: \(player.daysMissed)"
            playSound(forObject: "gainLevel")
        } else if dailies.count == 0 {
            imageView.image = UIImage(named: "advisorHappy")
            message = "Advisor: \"Add some Dailies when you are ready to begin your quest. But be warned, you have a much better chance of surviving if you start small and build on consistent wins.\""
        } else if dailiesDone == dailies.count {
            imageView.image = UIImage(named: "advisorHappy")
            message = "Advisor: \"Well done! Yesterday you completed all of your Dailies. Keep it up and you will actually complete the \(title) with your head intact!\" \n\n Days Until Victory: \(player.daysTil) \n Days Missed: \(player.daysMissed)"
            playSound(forObject: "completeDailies")
        } else if lostLevel == true {
            imageView.image = UIImage(named: "advisorMad")
            message = "Advisor: \"You have been defeated - returning to Level \(player.level) and the rank of \(UserDefaults.standard.object(forKey: "rank")!). If you can't keep up, perhaps you should set a reminder, drop a Daily, or make it easier.\" \n\n Days Until Victory: \(player.daysTil) \n Days Missed: \(player.daysMissed)"
            playSound(forObject: "loseLevel")
        } else {
            imageView.image = UIImage(named: "advisorMad")
            message = "Advisor: \"Yesterday you completed \(dailiesDone) of your \(dailies.count) dailies. You must do better today or you will surely be defeated.\" \n\n Days Until Victory: \(player.daysTil) \n Days Missed: \(player.daysMissed)"
            playSound(forObject: "missDailies")
        }
        
        lostLevel = false  // need lostLevel to stay true until decrement and correct message is shown, then it needs to be reset for next day?
        
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
        
        print("showedNewDayMessage: dailiesDone: \(dailiesDone) of \(dailies.count), daysMissed: \(player.daysMissed), lostLevel: \(lostLevel), gainedLevel: \(gainedLevel)")
    }
    
    func resetDailies() {
        for daily in dailies {
            daily.checked = false
        }
        
        dailiesDone = 0
        gainedLevel = false  // newly added
        
        print("resetDailies: dailiesDone: \(dailiesDone) of \(dailies.count), daysMissed: \(player.daysMissed), lostLevel: \(lostLevel), gainedLevel: \(gainedLevel)")
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

