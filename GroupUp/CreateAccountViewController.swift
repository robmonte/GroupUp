//
//  CreateAccountViewController.swift
//  GroupUp
//
//  Created by Michael McCrory on 3/20/17.
//  Copyright © 2017 GroupUp. All rights reserved.
//

import UIKit
import Firebase

class CreateAccountViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailField: CreateAccountTextField!
    @IBOutlet weak var confirmEmailField: CreateAccountTextField!
    @IBOutlet weak var usernameField: CreateAccountTextField!
    @IBOutlet weak var firstField: CreateAccountTextField!
    @IBOutlet weak var lastField: CreateAccountTextField!
    @IBOutlet weak var passwordField: CreateAccountTextField!
    @IBOutlet weak var confirmPasswordField: CreateAccountTextField!
    
    @IBOutlet weak var createButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailField.delegate = self
        confirmEmailField.delegate = self
        usernameField.delegate = self
        firstField.delegate = self
        lastField.delegate = self
        passwordField.delegate = self
        confirmPasswordField.delegate = self
        
        createButton.layer.cornerRadius = 5
        
        setAttributedStyle(text: emailField)
        setAttributedStyle(text: confirmEmailField)
        setAttributedStyle(text: usernameField)
        setAttributedStyle(text: firstField)
        setAttributedStyle(text: lastField)
        setAttributedStyle(text: passwordField)
        setAttributedStyle(text: confirmPasswordField)
    }
    
    func setAttributedStyle(text: CreateAccountTextField) {
        text.attributedPlaceholder = NSAttributedString(string: text.placeholder!, attributes: [NSForegroundColorAttributeName : UIColor.lightGray])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.emailField {
            self.confirmEmailField.becomeFirstResponder()
        }
        else if textField == self.confirmEmailField {
            self.usernameField.becomeFirstResponder()
        }
        else if textField == self.usernameField {
            self.firstField.becomeFirstResponder()
        }
        else if textField == self.firstField {
            self.lastField.becomeFirstResponder()
        }
        else if textField == self.lastField {
            self.passwordField.becomeFirstResponder()
        }
        else if textField == self.passwordField {
            self.confirmPasswordField.becomeFirstResponder()
        }
        else if textField == self.confirmPasswordField {
            textField.resignFirstResponder()
            createAccount(textField)
        }
        
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated:true)
    }
    
    @IBAction func createAccount(_ sender: Any) {
        if emailField.text! == "" || confirmEmailField.text! == "" || usernameField.text! == "" || firstField.text! == "" || lastField.text! == "" || passwordField.text! == "" || confirmPasswordField.text! == "" || usernameField.text! == "" {
            popup(title: "Invalid Input", message: "You must enter a value for all fields.")
        }
        else if passwordField.text!.characters.count < 8 {
            popup(title: "Weak Password", message: "Password must be at least 8 characters long.")
        }
        else if emailField.text! != confirmEmailField.text! {
            popup(title: "Invalid Input", message: "Emails do not match!")
        }
        else if passwordField.text! != confirmPasswordField.text! {
            popup(title: "Invalid Input", message: "Passwords do not match.")
        }
        else {
            FIRAuth.auth()?.createUser(withEmail: emailField.text!, password: passwordField.text!) { (user, error) in
                if let error = error {
                    self.popup(title: "Error", message: error.localizedDescription)
                    return
                }
                let changeRequest = user?.profileChangeRequest()
                changeRequest?.displayName = self.usernameField.text!
                changeRequest?.commitChanges() {(error) in
                    if let error = error {
                        self.popup(title: "Error", message: error.localizedDescription)
                        return
                    }
                }
                
                let rootRef = FIRDatabase.database().reference()
                let accountsRef = rootRef.child("Accounts")
                let newRef = accountsRef.child(self.usernameField.text!)
                let user:[String: String] = ["Username": self.usernameField.text!, "Email": self.emailField.text!, "First": self.firstField.text!, "Last": self.lastField.text!]
                
                newRef.setValue(user)

                _ = self.navigationController?.popViewController(animated:true)
            }
        }
    }
    
    func popup(title:String, message:String) {
        let alert = UIAlertController(title:"\(title)", message:"\(message)", preferredStyle:UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title:"OK", style:UIAlertActionStyle.cancel))
        self.present(alert, animated:true)
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
