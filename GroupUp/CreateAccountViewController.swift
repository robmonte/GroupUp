//
//  CreateAccountViewController.swift
//  GroupUp
//
//  Created by Michael McCrory on 3/20/17.
//  Copyright © 2017 GroupUp. All rights reserved.
//

import UIKit
import CoreData
import Firebase

class CreateAccountViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailField: CreateAccountTextField!
    @IBOutlet weak var usernameField: CreateAccountTextField!
    @IBOutlet weak var passwordField: CreateAccountTextField!
    @IBOutlet weak var confirmField: CreateAccountTextField!
    
    @IBOutlet weak var createButton: UIButton!
    
    private var accounts = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        confirmField.delegate = self
        
        createButton.layer.cornerRadius = 5
        
        usernameField.attributedPlaceholder = NSAttributedString(string: usernameField.placeholder!, attributes: [NSForegroundColorAttributeName : UIColor.lightGray])
        emailField.attributedPlaceholder = NSAttributedString(string: emailField.placeholder!, attributes: [NSForegroundColorAttributeName : UIColor.lightGray])
        passwordField.attributedPlaceholder = NSAttributedString(string: passwordField.placeholder!, attributes: [NSForegroundColorAttributeName : UIColor.lightGray])
        confirmField.attributedPlaceholder = NSAttributedString(string: confirmField.placeholder!, attributes: [NSForegroundColorAttributeName : UIColor.lightGray])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.emailField {
            self.usernameField.becomeFirstResponder()
        }
        else if textField == self.usernameField {
            self.passwordField.becomeFirstResponder()
        }
        else if textField == self.passwordField {
            self.confirmField.becomeFirstResponder()
        }
        else if textField == self.confirmField {
            textField.resignFirstResponder()
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
        if usernameField.text! == "" || emailField.text! == "" || passwordField.text! == "" || confirmField.text! == "" || usernameField.text! == "" {
            popup(title: "Invalid Input", message: "You must enter a value for all fields.")
        }
        else if passwordField.text!.characters.count < 8 {
            popup(title: "Weak Password", message: "Password must be at least 8 characters long.")
        }
        else if passwordField.text! != confirmField.text! {
            popup(title: "Invalid Input", message: "Passwords do not match.")
        } else {
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
                print("Account Created")
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
