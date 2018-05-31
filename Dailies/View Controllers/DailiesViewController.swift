//
//  ViewController.swift
//  Dailies
//
//  Created by Banana Viking on 5/30/18.
//  Copyright © 2018 Banana Viking. All rights reserved.
//

import UIKit

class DailiesViewController: UITableViewController {

    var dailies: [Daily]
    
    required init?(coder aDecoder: NSCoder) {
        dailies = [Daily]()
        
        let row0item = Daily()
        row0item.text = "Walk the dog"
        row0item.checked = false
        dailies.append(row0item)
        
        let row1item = Daily()
        row1item.text = "Brush my teeth"
        row1item.checked = true
        dailies.append(row1item)
        
        let row2item = Daily()
        row2item.text = "Learn iOS development"
        row2item.checked = true
        dailies.append(row2item)
        
        let row3item = Daily()
        row3item.text = "Soccer practice"
        row3item.checked = false
        dailies.append(row3item)
        
        let row4item = Daily()
        row4item.text = "Eat ice cream"
        row4item.checked = true
        dailies.append(row4item)
        
        super.init(coder: aDecoder)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dailies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "daily", for: indexPath)
        
        let daily = dailies[indexPath.row]
        
        configureText(for: cell, with: daily)
        
        configureCheckmark(for: cell, with: daily)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) {
            let daily = dailies[indexPath.row]
            daily.toggleChecked()
            configureCheckmark(for: cell, with: daily)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func configureCheckmark(for cell: UITableViewCell,
                            with daily: Daily) {
        
        if daily.checked {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
    }
    
    func configureText(for cell: UITableViewCell, with daily: Daily) {
        let label = cell.viewWithTag(1000) as! UILabel
        label.text = daily.text
    }

}

//import UIKit
//
//class ChecklistViewController: UITableViewController, AddItemViewControllerDelegate {
//
//    var checklist: Checklist!
//
//    func itemDetailViewControllerDidCancel(_ controller: ItemDetailViewController) {
//        navigationController?.popViewController(animated: true)
//    }
//
//    func itemDetailViewController(_ controller: ItemDetailViewController, didFinishAdding item: ChecklistItem) {
//        let newRowIndex = checklist.items.count
//        checklist.items.append(item)
//
//        let indexPath = IndexPath(row: newRowIndex, section: 0)
//        let indexPaths = [indexPath]
//        tableView.insertRows(at: indexPaths, with: .automatic)
//        navigationController?.popViewController(animated: true)
//    }
//
//    func itemDetailViewController(_ controller: ItemDetailViewController, didFinishEditing item: ChecklistItem) {
//        if let index = checklist.items.index(of: item) {
//            let indexPath = IndexPath(row: index, section: 0)
//            if let cell = tableView.cellForRow(at: indexPath) {
//                configureText(for: cell, with: item)
//            }
//        }
//        navigationController?.popViewController(animated: true)
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        navigationItem.largeTitleDisplayMode = .never
//        title = checklist.name
//        // Do any additional setup after loading the view, typically from a nib.
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return checklist.items.count
//    }
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "ChecklistItem", for: indexPath)
//        let item = checklist.items[indexPath.row]
//        configureText(for: cell, with: item)
//        configureCheckmark(for: cell, with: item)
//        return cell
//    }
//
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if let cell = tableView.cellForRow(at: indexPath) {
//            let item = checklist.items[indexPath.row]
//            item.toggleChecked()
//            configureCheckmark(for: cell, with: item)
//        }
//        tableView.deselectRow(at: indexPath, animated: true)
//    }
//
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        checklist.items.remove(at: indexPath.row)
//        let indexPaths = [indexPath]
//        tableView.deleteRows(at: indexPaths, with: .automatic)
//    }
//
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "AddItem" {
//            let controller = segue.destination as! ItemDetailViewController
//            controller.delegate = self
//        } else if segue.identifier == "EditItem" {
//            let controller = segue.destination as! ItemDetailViewController
//            controller.delegate = self
//            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
//                controller.itemToEdit = checklist.items[indexPath.row]
//            }
//        }
//    }
//
//    func configureCheckmark(for cell: UITableViewCell, with item: ChecklistItem) {
//        let label = cell.viewWithTag(1001) as! UILabel
//        label.textColor = view.tintColor
//        if item.checked {
//            label.text = "√"
//        } else {
//            label.text = ""
//        }
//    }
//
//    func configureText(for cell: UITableViewCell, with item: ChecklistItem) {
//        let label = cell.viewWithTag(1000) as! UILabel
//        label.text = "\(item.text)"
//    }
//}
//
