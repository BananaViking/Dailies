//
//  ViewController.swift
//  Dailies
//
//  Created by Banana Viking on 5/30/18.
//  Copyright © 2018 Banana Viking. All rights reserved.
//

import UIKit

class DailiesViewController: UITableViewController, DailyDetailViewControllerDelegate {
    
    var dailies = [Daily]()
    var dailiesDone = 0
    var streak = 0
    var level = "Beginner"
    
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
                checkDailiesComplete()
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
    override func viewDidLoad() {
        super.viewDidLoad()
        loadDailies()
        for daily in dailies where daily.checked {
            dailiesDone += 1
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        let lastLaunchDate = dateFormatter.string(from: UserDefaults.standard.object(forKey: "lastLaunch") as! Date)
        
        let today = Date()
        let todayDate = dateFormatter.string(from: today)
        
        print("lastLaunch: \(UserDefaults.standard.object(forKey: "lastLaunch") as! Date)")
        print("today: \(today)")
        print("lastLaunchDate: \(lastLaunchDate)")
        print("todayDate: \(todayDate)")
        
        if lastLaunchDate == todayDate { // change this back to !=
            let alert = UIAlertController(title: "Welcome back!", message: "Yesterday you completed \(dailiesDone) of \(dailies.count) dailies.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "I can get them all done today!", style: .default, handler: nil))
            
            present(alert, animated: true, completion: nil)
            
            for daily in dailies {
                if daily.checked {
                    daily.checked = false
                }
            }
            
            dailiesDone = 0
        } else {
            print("You have already logged in today.")
        }
    }
    
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
    }
    
    func checkDailiesComplete() {
        let alert = UIAlertController(title: "NICE WORK!", message: "You completed all of your Dailies today! \n\nStreak: \(streak) \nLevel: \(level)", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Gimme a high five! ✋", style: .default, handler: nil))
        
        if dailiesDone == dailies.count {
            present(alert, animated: true, completion: nil)
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

