//
//  MessageViewController.swift
//  Dailies
//
//  Created by Banana Viking on 6/30/18.
//  Copyright © 2018 Banana Viking. All rights reserved.
//

import UIKit

class MessageViewController: UIViewController {
    
    @IBAction func dismissMessageButton(_ sender: UIButton) {
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        if let imageView = self.view.viewWithTag(10) as? UIImageView {
            imageView.layer.cornerRadius = 8
            imageView.image = UIImage(named: "advisorHappy")
        }
        
        if let textView = self.view.viewWithTag(11) as? UITextView {
            textView.text = "Welcome to Habit Quest! My name is Maya, and I will be your advisor on your journey. Add some Dailies when you are ready to begin the Skeleton Quest. You have a much better chance of surviving if you start small and build on wins."
        }
        
        if let dismissMessageButton = self.view.viewWithTag(12) as? UIButton {
            dismissMessageButton.layer.cornerRadius = 8
            dismissMessageButton.setTitle("Start Game", for: .normal)
        }
    }
}
