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
    
    public var email:String = ""
    public var username:String = ""
    
    var handle: FIRAuthStateDidChangeListenerHandle?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func logoutPressed(_ sender: Any) {
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
            _ = navigationController?.popViewController(animated:true)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated:true)
        
        handle = FIRAuth.auth()?.addStateDidChangeListener() { (auth, user) in
            self.usernameLabel.text! = "Welcome back \((user?.displayName!)!)"
            self.username = (user?.displayName!)!
        }
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
        // [START remove_auth_listener]
        FIRAuth.auth()?.removeStateDidChangeListener(handle!)
        // [END remove_auth_listener]
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
