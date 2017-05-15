//
//  ViewController.swift
//  MyChat
//
//  Created by Nguyen Duy Khanh on 4/13/17.
//  Copyright © 2017 Nguyen Duy Khanh. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogOut))
        if FIRAuth.auth()?.currentUser?.uid == nil {
            handleLogOut()
        }
    }
    
    func handleLogOut() {
        do {
            try FIRAuth.auth()?.signOut()
        } catch let logOutError {
            print(logOutError)
        }
        
        let loginController = LoginController()
        present(loginController, animated: true, completion: nil)
    }
}

