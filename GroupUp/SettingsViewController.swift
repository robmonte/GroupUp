//
//  SettingsViewController.swift
//  GroupUp
//
//  Created by Robert Montefusco on 3/19/17.
//  Copyright © 2017 GroupUp. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var rememberUsernameToggle: UISwitch!
    public var username:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        
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
        let defaults = UserDefaults.standard
        
        if rememberSwitch.isOn {
            defaults.set(username, forKey: "rememberUsername")
            defaults.set(true, forKey: "rememberState")
        }
        else {
            let blank:String = ""
            defaults.set(blank, forKey: "rememberUsername")
            defaults.set(false, forKey: "rememberState")
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
