//
//  Daily.swift
//  Dailies
//
//  Created by Banana Viking on 5/30/18.
//  Copyright © 2018 Banana Viking. All rights reserved.
//

import Foundation
import UserNotifications

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
    
    class func nextDailyID() -> Int {
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
            
            //        let content = UNMutableNotificationContent()
            //        content.title = "Hello!"
            //        content.body = "I am a local notification"
            //        content.sound = UNNotificationSound.default()
            //
            //        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            //        let request = UNNotificationRequest(identifier: "MyNotification", content: content, trigger: trigger)
            //        center.add(request)
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





