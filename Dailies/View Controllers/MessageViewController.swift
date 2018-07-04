//
//  MessageViewController.swift
//  Dailies
//
//  Created by Banana Viking on 6/30/18.
//  Copyright © 2018 Banana Viking. All rights reserved.
//

import UIKit

class MessageViewController: UIViewController {
    
    let dailiesVC = DailiesViewController()
    
    
    
    @IBAction func dismissMessageButton(_ sender: UIButton) {
        view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        let noDailies = UserDefaults.standard.bool(forKey: "noDailies")
        let gainLevel = UserDefaults.standard.bool(forKey: "gainLevel")
        let completeDailies = UserDefaults.standard.bool(forKey: "completeDailies")
        let loseLevel = UserDefaults.standard.bool(forKey: "loseLevel")
        let missDailies = UserDefaults.standard.bool(forKey: "missDailies")
        let beatGame = UserDefaults.standard.bool(forKey: "beatGame")
        let lostGame = UserDefaults.standard.bool(forKey: "lostGame")
        
        guard let imageView = view.viewWithTag(10) as? UIImageView else { return }
        imageView.layer.cornerRadius = 8
        
        guard let textView = view.viewWithTag(11) as? UITextView else { return }
        
        guard let dismissMessageButton = view.viewWithTag(12) as? UIButton else { return }
        dismissMessageButton.layer.cornerRadius = 8
        
        if launchedBefore == false {  // check to make sure you need ALL the UD resets even if you need SOME
            imageView.image = UIImage(named: "advisorHappy")
            textView.text = "Welcome to Habit Quest! My name is Maya, and I will be your advisor on your journey. Add some Dailies when you are ready to begin the Skeleton Quest. You have a much better chance of surviving if you start small and build on wins."
            dismissMessageButton.setTitle("Start Game", for: .normal)
            dailiesVC.playSound(forObject: "firstLaunch")
        } else if beatGame == true {
            imageView.image = UIImage(named: "beatGame")
            textView.text = "You have defeated the necromancer and saved the world. Go have a beer. You earned it."
            dismissMessageButton.setTitle("DRINK BEER", for: .normal)
            dailiesVC.playSound(forObject: "firstLaunch")
        } else if lostGame == true {
            imageView.image = UIImage(named: "lostGame")
            textView.text = "You have been killed by the necromancer and his minions. Now the world will surely plunge into eternal darkness."
            dismissMessageButton.setTitle("TRY NOT TO FUCK IT UP THIS TIME", for: .normal)
            dailiesVC.playSound(forObject: "loseLevel")
        } else if noDailies == true {
            imageView.image = UIImage(named: "advisorMad")
            textView.text = "You must add at least one Daily before returning to your quest. Hurry up before it's too late!"
            dismissMessageButton.setTitle("OK", for: .normal)
            dailiesVC.playSound(forObject: "noDailies")
        } else if gainLevel == true {
            imageView.image = UIImage(named: "advisorHappy")
            textView.text = "Victory! You have vanquished the enemy and gained a level! There is no time to rest, however, as your next quest has already begun!"
            dismissMessageButton.setTitle("OK", for: .normal)
            dailiesVC.playSound(forObject: "gainLevel")
            UserDefaults.standard.set(false, forKey: "gainLevel")
        } else if completeDailies == true {
            imageView.image = UIImage(named: "advisorHappy")
            textView.text = "Well done! Yesterday you completed all of your Dailies. Keep it up and you will actually complete this quest with your head intact!"
            dismissMessageButton.setTitle("OK", for: .normal)
            dailiesVC.playSound(forObject: "completeDailies")
            UserDefaults.standard.set(false, forKey: "completeDailies")
        } else if loseLevel == true {
            imageView.image = UIImage(named: "advisorMad")
            textView.text = "You have been defeated and lost a level. If you can't keep up, perhaps you should set a reminder, drop a Daily, or make it easier."
            dismissMessageButton.setTitle("OK", for: .normal)
            dailiesVC.playSound(forObject: "loseLevel")
            UserDefaults.standard.set(false, forKey: "loseLevel")
        } else if missDailies == true {
            imageView.image = UIImage(named: "advisorMad")
            textView.text = "You did not complete your dailies yesterday. You must do better today or you will surely be defeated."
            dismissMessageButton.setTitle("OK", for: .normal)
            dailiesVC.playSound(forObject: "missDailies")
            UserDefaults.standard.set(false, forKey: "missDailies")
        }
    }
}

