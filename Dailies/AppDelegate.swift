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
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        // the following commented out code was used before adding the nil coalescing operator to lastLaunch which hopefully makes this unnecessary:
//        if UserDefaults.standard.object(forKey: "lastLaunch") as? Date == nil {
//            UserDefaults.standard.set(Date(), forKey: "lastLaunch")
//        }
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        UserDefaults.standard.set(Date(), forKey: "lastLaunch")
        print(UserDefaults.standard.object(forKey: "lastLaunch")!)
        UserDefaults.standard.synchronize()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        // this is giving a warning in the compiler because on app launch there is already an alert active
//        let alert = UIAlertController(title: "appDidBecomeActive", message: "test message", preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//        self.window?.rootViewController?.present(alert, animated: true, completion: nil)

    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        UserDefaults.standard.set(Date(), forKey: "lastLaunch")
        print(UserDefaults.standard.object(forKey: "lastLaunch")!)
        UserDefaults.standard.synchronize()
    }
    
    // MARK: - User Notification Delegates
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Received local notification \(notification)")
    }
    
    
}

