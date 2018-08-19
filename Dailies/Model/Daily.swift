//
//  Daily.swift
//  Dailies
//
//  Created by Banana Viking on 5/30/18.
//  Copyright © 2018 Banana Viking. All rights reserved.
//

import UserNotifications
import SwiftyUserDefaults

class Daily: NSObject, Codable {
    var text = ""
    var checked = false
    var dueDate = Date()
    var shouldRemind = false
    var dailyID: Int
    
    override init() {
        dailyID = Daily.nextDailyID()
        super.init()
    }
    
    func toggleChecked() {
        checked = !checked
    }
    
    class func nextDailyID() -> Int {  // change this to SwiftyUD? still need the .synchronize()?
        let userDefaults = UserDefaults.standard
        let dailyID = userDefaults.integer(forKey: "DailyID")
        userDefaults.set(dailyID + 1, forKey: "DailyID")
        userDefaults.synchronize()
        return dailyID
    }
    
    func scheduleNotification() {
        removeNotification()
        if shouldRemind {
            let content = UNMutableNotificationContent()
            content.title = "Reminder:"
            content.body = text
            content.sound = UNNotificationSound.default()
            
            let calendar = Calendar(identifier: .gregorian)
            let components = calendar.dateComponents([.hour, .minute], from: dueDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(identifier: "\(dailyID)", content: content, trigger: trigger)
            let center = UNUserNotificationCenter.current()
            center.add(request)
            
            print("Scheduled: \(request) for dailyID: \(dailyID)")
        }
    }
    
    func removeNotification() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["\(dailyID)"])
    }
    
    deinit {
        removeNotification()
    }
}





