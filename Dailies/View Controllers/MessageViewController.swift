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
        }
    }
}

