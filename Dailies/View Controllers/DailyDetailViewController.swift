//
//  DailyDetailViewController.swift
//  Dailies
//
//  Created by Banana Viking on 5/31/18.
//  Copyright © 2018 Banana Viking. All rights reserved.
//

import UIKit

protocol DailyDetailViewControllerDelegate: class {
    func dailyDetailViewControllerDidCancel(_ controller: DailyDetailViewController)
    
    func dailyDetailViewController(_ controller: DailyDetailViewController, didFinishAdding daily: Daily)
    
    func dailyDetailViewController(_ controller: DailyDetailViewController, didFinishEditing daily: Daily)
}

class DailyDetailViewController: UITableViewController, UITextFieldDelegate {

    weak var delegate: DailyDetailViewControllerDelegate?
    
    var dailyToEdit: Daily?
    
    // MARK: - Actions
    @IBAction func cancel() {
        delegate?.dailyDetailViewControllerDidCancel(self)
    }
    
    @IBAction func done() {
        if let dailyToEdit = dailyToEdit {
            dailyToEdit.text = textField.text!
            
            delegate?.dailyDetailViewController(self, didFinishEditing: dailyToEdit)
        } else {
            let daily = Daily()
            daily.text = textField.text!
            daily.checked = false
            
            delegate?.dailyDetailViewController(self, didFinishAdding: daily)
        }
    }
    
    // MARK: - Outlets
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    
    @IBOutlet weak var shouldRemindSwitch: UISwitch!
    
    @IBOutlet weak var dueDateLabel: UILabel!
    
    //MARK: - tableView Delegates
    // stops the cell from highlighting when tap just outside the text field
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
    // MARK: - Functions
    // activates the text field when page is loaded without having to select it first
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textField.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let dailyToEdit = dailyToEdit {
            title = "Edit Daily"
            textField.text = dailyToEdit.text
            doneBarButton.isEnabled = true
        }
    }

    // disables doneBarButton if textField is empty
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let oldText = textField.text!
        let stringRange = Range(range, in: oldText)!
        let newText = oldText.replacingCharacters(in: stringRange, with: string)
        
        doneBarButton.isEnabled = !newText.isEmpty
        
        return true
    }
}
