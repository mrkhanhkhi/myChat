//
//  MessagesViewController.swift
//  MyChat
//
//  Created by Nguyen Duy Khanh on 4/13/17.
//  Copyright © 2017 Nguyen Duy Khanh. All rights reserved.
//

import UIKit
import Firebase

class MessagesViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let image = UIImage(named: "modify")
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogOut))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleNewMessage))
        checkIfUserLoggedIn()
    }
    
    func checkIfUserLoggedIn () {
        if FIRAuth.auth()?.currentUser?.uid == nil {
            perform(#selector(handleLogOut), with: nil, afterDelay: 0)
        } else {
         fetchUserAndSetupNavBarTitle()
        }
    }
    
    func fetchUserAndSetupNavBarTitle() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot)
            if let dictionary = snapshot.value as? [String:AnyObject] {
                let user = User()
                user.setValuesForKeys(dictionary)
                self.setupNavbarWithUser(user: user)
            }
        })
    }
    
    func setupNavbarWithUser(user:User) {
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        
        let profileImageview = UIImageView()
        profileImageview.translatesAutoresizingMaskIntoConstraints = false

        if let profileImageUrl = user.profileImageUrl {
            profileImageview.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        containerView.addSubview(profileImageview)


        
        profileImageview.contentMode = .scaleAspectFill
        profileImageview.layer.cornerRadius = 20
        profileImageview.clipsToBounds = true
        profileImageview.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageview.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageview.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageview.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let nameLabel = UILabel()
        containerView.addSubview(nameLabel)
        nameLabel.text = user.name
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.leftAnchor.constraint(equalTo: profileImageview.rightAnchor, constant:5).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageview.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive =  true
        nameLabel.heightAnchor.constraint(equalTo: profileImageview.heightAnchor).isActive = true
        
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
        
        self.navigationItem.titleView = titleView
        titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showChatController)))
        
    }
    
    func showChatController() {
        let chatLogControlelr = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        navigationController?.pushViewController(chatLogControlelr, animated: true)
    }
    
    func handleNewMessage() {
        let newMessageController = NewMessageController()
        let navController = UINavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
    }
    
    func handleLogOut() {
        do {
            try FIRAuth.auth()?.signOut()
        } catch let logOutError {
            print(logOutError)
        }
        
        let loginController = LoginController()
        loginController.messageController = self
        present(loginController, animated: true, completion: nil)
    }
}

