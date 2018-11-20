//
//  AppDelegate.swift
//  Dailies
//
//  Created by Banana Viking on 5/30/18.
//  Copyright © 2018 Banana Viking. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        var preferredStatusBarStyle: UIStatusBarStyle {
            return .lightContent
        }
        
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        UserDefaults.standard.set(true, forKey: "launchedBefore")
        UserDefaults.standard.set(Date(), forKey: "lastLaunch")
        UserDefaults.standard.synchronize()
        print("date entered background: \(UserDefaults.standard.object(forKey: "lastLaunch")!)")
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        UserDefaults.standard.set(true, forKey: "launchedBefore")
        UserDefaults.standard.set(Date(), forKey: "lastLaunch")
        UserDefaults.standard.synchronize()
        print("date terminated: \(UserDefaults.standard.object(forKey: "lastLaunch")!)")
    }
    
    // MARK: - User Notification Delegates
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Received local notification \(notification)")
    }
}
