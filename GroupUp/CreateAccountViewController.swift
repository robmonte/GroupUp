//
//  CreateAccountViewController.swift
//  GroupUp
//
//  Created by Robert Montefusco on 3/18/17.
//  Copyright © 2017 GroupUp. All rights reserved.
//

import UIKit

class CreateAccountViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameField: CreateAccountTextField!
    @IBOutlet weak var firstField: CreateAccountTextField!
    @IBOutlet weak var lastField: CreateAccountTextField!
    @IBOutlet weak var passwordField: CreateAccountTextField!
    @IBOutlet weak var confirmField: CreateAccountTextField!
    
    @IBOutlet weak var createButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameField.delegate = self
        firstField.delegate = self
        lastField.delegate = self
        passwordField.delegate = self
        confirmField.delegate = self
        
        createButton.layer.cornerRadius = 5
        
        usernameField.attributedPlaceholder = NSAttributedString(string: usernameField.placeholder!, attributes: [NSForegroundColorAttributeName : UIColor.lightGray])
        firstField.attributedPlaceholder = NSAttributedString(string: firstField.placeholder!, attributes: [NSForegroundColorAttributeName : UIColor.lightGray])
        lastField.attributedPlaceholder = NSAttributedString(string: lastField.placeholder!, attributes: [NSForegroundColorAttributeName : UIColor.lightGray])
        passwordField.attributedPlaceholder = NSAttributedString(string: passwordField.placeholder!, attributes: [NSForegroundColorAttributeName : UIColor.lightGray])
        confirmField.attributedPlaceholder = NSAttributedString(string: confirmField.placeholder!, attributes: [NSForegroundColorAttributeName : UIColor.lightGray])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.usernameField {
            self.firstField.becomeFirstResponder()
        }
        else if textField == self.firstField {
            self.lastField.becomeFirstResponder()
        }
        else if textField == self.lastField {
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
