//
//  LoginViewController.swift
//  GroupUp
//
//  Created by Robert Montefusco on 3/17/17.
//  Copyright © 2017 GroupUp. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameField: LoginTextField!
    @IBOutlet weak var passwordField: LoginTextField!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameField.delegate = self
        passwordField.delegate = self
        
        loginButton.layer.cornerRadius = 5
        
        createAccountButton.titleLabel?.textAlignment = NSTextAlignment.center
        createAccountButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        
        usernameField.attributedPlaceholder = NSAttributedString(string: usernameField.placeholder!, attributes: [NSForegroundColorAttributeName : UIColor.gray])
        passwordField.attributedPlaceholder = NSAttributedString(string: passwordField.placeholder!, attributes: [NSForegroundColorAttributeName : UIColor.gray])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.usernameField {
            self.passwordField.becomeFirstResponder()
        }
        else if textField == self.passwordField {
            textField.resignFirstResponder()
        }
        
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated:true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //    override func viewWillDisappear(_ animated: Bool) {
    //        self.navigationController?.setNavigationBarHidden(false, animated:true)
    //    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
