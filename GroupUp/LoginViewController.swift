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
import MapKit

class LoginViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var emailField: LoginTextField!
    @IBOutlet weak var passwordField: LoginTextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!
    
    private var accounts = [NSManagedObject]()
    private var location = CLLocationManager()
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        let defaults = UserDefaults.standard
        
        emailField.delegate = self
        passwordField.delegate = self
        
        loginButton.layer.cornerRadius = 5
        loginButton.layer.borderWidth = 1
        loginButton.layer.borderColor = UIColor(hex: 0x007AFF, alpha: 1.0).cgColor //UIColor(hex: 0x5086E8, alpha: 1.0).cgColor
        
        createAccountButton.titleLabel?.textAlignment = NSTextAlignment.center
        createAccountButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        
        emailField.text = defaults.object(forKey: "rememberEmail") as! String?
        emailField.attributedPlaceholder = NSAttributedString(string: emailField.placeholder!, attributes: [NSForegroundColorAttributeName : UIColor.gray, NSFontAttributeName: UIFont.systemFont(ofSize: 20)])
        
        passwordField.attributedPlaceholder = NSAttributedString(string: passwordField.placeholder!, attributes: [NSForegroundColorAttributeName : UIColor.gray, NSFontAttributeName: UIFont.systemFont(ofSize: 20)])
        
        let getRefresh:Int = defaults.object(forKey: "rememberRefresh") as? Int ?? 5
        print(getRefresh)
        SettingsViewController.refreshRate = getRefresh
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
    
    override func viewDidAppear(_ animated: Bool) {
        loginButton.isHidden = false
        if(CLLocationManager.locationServicesEnabled()) {
            location.delegate = self
            location.desiredAccuracy = kCLLocationAccuracyBest
            location.requestAlwaysAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            print("Location access granted.")
        }
        else {
            print("User declined location privileges.")
        }
    }
    
    @IBAction func loginFirebase(_ sender: Any) {
        self.loginButton.isHidden = true
        if let email = self.emailField.text, let password = self.passwordField.text {
                FIRAuth.auth()?.signIn(withEmail: email, password: password) { (user, error) in
                    if error != nil {
                        self.loginButton.isHidden = false
                        self.popup(title: "Invalid input", message: "Username or password is incorrect. Please try again.")
                        return
                    }
                    
                    print("Login successful")
                    self.performSegue(withIdentifier: "loginSegue", sender: nil)
                }
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
            let backItem = UIBarButtonItem()
            backItem.title = "Log out"
            navigationItem.backBarButtonItem = backItem
        }
    }
}
