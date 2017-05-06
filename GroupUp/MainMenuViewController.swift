//
//  MainMenuViewController.swift
//  GroupUp
//
//  Created by Robert Montefusco on 3/19/17.
//  Copyright © 2017 GroupUp. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications

class MainMenuViewController: UIViewController {
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var viewGroupsButton: UIButton!
    @IBOutlet weak var createGroupButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
    public var email:String = ""
    public var username:String = ""
    
    var handle: FIRAuthStateDidChangeListenerHandle?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Main Menu"
        usernameLabel.text = "Welcome back "
        
        viewGroupsButton.layer.cornerRadius = 5
        viewGroupsButton.layer.borderWidth = 1
        viewGroupsButton.layer.borderColor = UIColor(hex: 0x007AFF, alpha: 1.0).cgColor
        
        createGroupButton.layer.cornerRadius = 5
        createGroupButton.layer.borderWidth = 1
        createGroupButton.layer.borderColor = UIColor(hex: 0x007AFF, alpha: 1.0).cgColor
        
        settingsButton.layer.cornerRadius = 5
        settingsButton.layer.borderWidth = 1
        settingsButton.layer.borderColor = UIColor(hex: 0x007AFF, alpha: 1.0).cgColor
        
        let rootRef = FIRDatabase.database().reference()
        let groupsRef = rootRef.child("Accounts")
        let query = groupsRef.queryOrdered(byChild: "Email").queryEqual(toValue: email)
        
        query.observe(.value, with: { snapshot in
            let userGroups = snapshot.value as? NSDictionary
            let retList = userGroups?.allKeys as? [String]
            print(retList ?? [""])
            
            self.username = (retList?[0])!
            self.usernameLabel.text = "Welcome back \(self.username)"
            
            let userRef = groupsRef.child(self.username)
            userRef.observe(.value, with: { snapshotFirst in
                let userInfo = snapshotFirst.value as? NSDictionary
                let first = userInfo?["First"]
                
                self.usernameLabel.text = "Welcome back \(first!)"
                
                self.viewGroupsButton.isHidden = false
                self.createGroupButton.isHidden = false
                self.settingsButton.isHidden = false
            })
            
        })


        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated:true)
        self.navigationController?.navigationBar.tintColor = UIColor.red
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let notify = UNUserNotificationCenter.current()
        notify.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if !granted {
                print(error.debugDescription)
            }
            else {
                print("Notification access granted.")
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.navigationBar.tintColor = UIColor(hex: 0x007AFF, alpha: 1.0)
        
        // [START remove_auth_listener]
        if let handle = handle {
            FIRAuth.auth()?.removeStateDidChangeListener(handle)
        }
        // [END remove_auth_listener]
        
        if (self.isMovingFromParentViewController) {
            let firebaseAuth = FIRAuth.auth()
            do {
                try firebaseAuth?.signOut()
                _ = self.navigationController?.popViewController(animated:true)
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
        }
    }

    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? SettingsViewController {
            destinationVC.email = self.email
        }
        else if let destinationVC = segue.destination as? CreateGroupViewController {
            destinationVC.username = self.username
        }
        else if let destinationVC = segue.destination as? GroupsListTableViewController {
            destinationVC.username = self.username
        }
    }
}
