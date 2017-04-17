//
//  LoginViewController.swift
//  GroupUp
//
//  Created by Robert Montefusco on 3/17/17.
//  Copyright © 2017 GroupUp. All rights reserved.
//

import UIKit
import CoreData
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailField: LoginTextField!
    @IBOutlet weak var passwordField: LoginTextField!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!
    
    private var accounts = [NSManagedObject]()
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        
        emailField.delegate = self
        passwordField.delegate = self
        
        loginButton.layer.cornerRadius = 5
        loginButton.layer.borderWidth = 1
        loginButton.layer.borderColor = UIColor.gray.cgColor
        
        createAccountButton.titleLabel?.textAlignment = NSTextAlignment.center
        createAccountButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        
        emailField.text = defaults.object(forKey: "rememberEmail") as! String?
        emailField.attributedPlaceholder = NSAttributedString(string: emailField.placeholder!, attributes: [NSForegroundColorAttributeName : UIColor.gray, NSFontAttributeName: UIFont.systemFont(ofSize: 20)])
        
        passwordField.attributedPlaceholder = NSAttributedString(string: passwordField.placeholder!, attributes: [NSForegroundColorAttributeName : UIColor.gray, NSFontAttributeName: UIFont.systemFont(ofSize: 20)])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.emailField {
            self.passwordField.becomeFirstResponder()
        }
        else if textField == self.passwordField {
            textField.resignFirstResponder()
            loginFirebase(textField)
        }
        
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        emailField.text = defaults.object(forKey: "rememberEmail") as! String?
        passwordField.text = ""
        
        self.navigationController?.setNavigationBarHidden(true, animated:true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func loginFirebase(_ sender: Any) {
        if let email = self.emailField.text, let password = self.passwordField.text {
                // [START headless_email_auth]
                FIRAuth.auth()?.signIn(withEmail: email, password: password) { (user, error) in
                    // [START_EXCLUDE]
                    if let error = error {
                        self.popup(title: "Error", message: error.localizedDescription)
                        return
                    }
                    print("Login successful")
                    self.performSegue(withIdentifier: "loginSegue", sender: nil)
                    // [END_EXCLUDE]
                }
                // [END headless_email_auth]
        }
    }
    
    func popup(title:String, message:String) {
        let alert = UIAlertController(title:"\(title)", message:"\(message)", preferredStyle:UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title:"OK", style:UIAlertActionStyle.cancel))
        self.present(alert, animated:true)
    }
    //    override func viewWillDisappear(_ animated: Bool) {
    //        self.navigationController?.setNavigationBarHidden(false, animated:true)
    //    }

    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? MainMenuViewController {
            destinationVC.email = emailField.text!
        }
    }
}
