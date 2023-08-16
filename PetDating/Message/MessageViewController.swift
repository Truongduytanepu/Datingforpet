//
//  MessageViewController.swift
//  FoodAppIOS
//
//  Created by Trương Duy Tân on 23/07/2023.
//

import UIKit
import Firebase
import FirebaseAuth

class MessageViewController: UIViewController{
    
    
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var cell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        
    }
}

