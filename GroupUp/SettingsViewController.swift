//
//  SettingsViewController.swift
//  GroupUp
//
//  Created by Robert Montefusco on 3/19/17.
//  Copyright © 2017 GroupUp. All rights reserved.
//

import UIKit
import Firebase

class SettingsViewController: UIViewController {

    @IBOutlet weak var rememberUsernameToggle: UISwitch!
    
    public var email:String = ""
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rememberUsernameToggle.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        let check:Bool = defaults.object(forKey: "rememberState") as? Bool ?? false
        if check == true {
            rememberUsernameToggle.setOn(true, animated: true)
        }
        else {
            rememberUsernameToggle.setOn(false, animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated:true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func switchChanged(rememberSwitch: UISwitch) {
        if rememberSwitch.isOn {
            defaults.set(email, forKey: "rememberEmail")
            defaults.set(true, forKey: "rememberState")
        }
        else {
            let blank:String = ""
            defaults.set(blank, forKey: "rememberEmail")
            defaults.set(false, forKey: "rememberState")
        }        
    }
    
    @IBAction func deleteAccount(_ sender: Any) {
        let user = FIRAuth.auth()?.currentUser
        
        user?.delete { error in
            if let error = error {
                print(error)
            } else {
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
