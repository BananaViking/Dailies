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
        super.viewDidLoad()
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
        
        guard let messageLabel = view.viewWithTag(11) as? UILabel else { return }
        
        guard let dismissMessageButton = view.viewWithTag(12) as? UIButton else { return }
        dismissMessageButton.layer.cornerRadius = 8
        
        if launchedBefore == false {  // check to make sure you need ALL the UD resets even if you need SOME
            imageView.image = UIImage(named: "advisorHappy")
            messageLabel.text = "Welcome to Habit Quest! My name is Maya, and I will be your advisor on your journey. Add some Dailies when you are ready to begin the Skeleton Quest. But be warned, you have a much better chance of surviving if you start small and build on wins."
            dismissMessageButton.setTitle("Start Game", for: .normal)
            dailiesVC.playSound(forObject: "firstLaunch")
        } else if beatGame == true {
            imageView.image = UIImage(named: "beatGame")
            messageLabel.text = "After many hard fought battles, you have finally defeated the necromancer and all of his minions. Peace has been restored to the land. Sleep well tonight adventurer; you have earned it."
            dismissMessageButton.setTitle("Start a New Game", for: .normal)
            dailiesVC.playSound(forObject: "beatGame")
        } else if lostGame == true {
            imageView.image = UIImage(named: "lostGame")
            messageLabel.text = "You have been defeated by the necromancer and his minions. The world will surely plunge into eternal darkness. If only you could have been stronger..."
            dismissMessageButton.setTitle("Try Again", for: .normal)
            dailiesVC.playSound(forObject: "lostGame")
        } else if noDailies == true {
            imageView.image = UIImage(named: "advisorMad")
            messageLabel.text = "You must add at least one Daily before returning to your quest. Hurry up before it's too late! 2 You must add at least one Daily before returning to your quest. Hurry up before it's too late! 3 You must add at least one Daily before returning to your quest. Hurry up before it's too late!"
            dismissMessageButton.setTitle("OK", for: .normal)
            dailiesVC.playSound(forObject: "noDailies")
        } else if gainLevel == true {
            imageView.image = UIImage(named: "advisorHappy")
            messageLabel.text = "Victory! You have vanquished the enemy and gained a level! There is no time to rest, however, as your next quest has already begun!"
            dismissMessageButton.setTitle("OK", for: .normal)
            dailiesVC.playSound(forObject: "gainLevel")
            UserDefaults.standard.set(false, forKey: "gainLevel")
        } else if completeDailies == true {
            imageView.image = UIImage(named: "advisorHappy")
            messageLabel.text = "Well done! Yesterday you completed all of your Dailies. Keep it up and you will actually complete this quest with your head intact!"
            dismissMessageButton.setTitle("OK", for: .normal)
            dailiesVC.playSound(forObject: "completeDailies")
        } else if loseLevel == true {
            imageView.image = UIImage(named: "advisorMad")
            messageLabel.text = "You have been defeated and lost a level. If you can't keep up, perhaps you should set a reminder, drop a Daily, or make it easier."
            dismissMessageButton.setTitle("OK", for: .normal)
            dailiesVC.playSound(forObject: "loseLevel")
            UserDefaults.standard.set(false, forKey: "loseLevel")
        } else if missDailies == true {
            imageView.image = UIImage(named: "advisorMad")
            messageLabel.text = "You did not complete your dailies yesterday. You must do better today or you will surely be defeated."
            dismissMessageButton.setTitle("OK", for: .normal)
            dailiesVC.playSound(forObject: "missDailies")
        }
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
}

