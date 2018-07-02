//
//  MessageViewController.swift
//  Dailies
//
//  Created by Banana Viking on 6/30/18.
//  Copyright © 2018 Banana Viking. All rights reserved.
//

import UIKit

class MessageViewController: UIViewController {
    var launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
    var beatGame = UserDefaults.standard.bool(forKey: "beatGame")
    var lostGame = UserDefaults.standard.bool(forKey: "lostGame")
    
    @IBAction func dismissMessageButton(_ sender: UIButton) {
        view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        
        guard let imageView = view.viewWithTag(10) as? UIImageView else { return }
        imageView.layer.cornerRadius = 8
        
        guard let textView = view.viewWithTag(11) as? UITextView else { return }
        
        guard let dismissMessageButton = view.viewWithTag(12) as? UIButton else { return }
        dismissMessageButton.layer.cornerRadius = 8
        
        if launchedBefore == false {
            imageView.image = UIImage(named: "advisorHappy")
            textView.text = "Welcome to Habit Quest! My name is Maya, and I will be your advisor on your journey. Add some Dailies when you are ready to begin the Skeleton Quest. You have a much better chance of surviving if you start small and build on wins."
            dismissMessageButton.setTitle("Start Game", for: .normal)
        } else if beatGame == true {
            imageView.image = UIImage(named: "beatGame")
            textView.text = "You have defeated the necromancer and saved the world. Go have a beer. You earned it."
            dismissMessageButton.setTitle("DRINK BEER", for: .normal)
        } else if lostGame == true {
            imageView.image = UIImage(named: "enemy10")
            textView.text = "You have been defeated by the necromancer and his minions as the world plunges into eternal darkness."
            dismissMessageButton.setTitle("TRY NOT TO FUCK IT UP THIS TIME", for: .normal)
        }
    }
}

