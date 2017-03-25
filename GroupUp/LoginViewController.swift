//
//  LoginViewController.swift
//  GroupUp
//
//  Created by Robert Montefusco on 3/17/17.
//  Copyright © 2017 GroupUp. All rights reserved.
//

import UIKit
import CoreData

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameField: LoginTextField!
    @IBOutlet weak var passwordField: LoginTextField!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!
    
    private var accounts = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        
        usernameField.delegate = self
        passwordField.delegate = self
        
        loginButton.layer.cornerRadius = 5
        loginButton.layer.borderWidth = 1
        loginButton.layer.borderColor = UIColor.gray.cgColor
        
        createAccountButton.titleLabel?.textAlignment = NSTextAlignment.center
        createAccountButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        
        usernameField.text = defaults.object(forKey: "rememberUsername") as! String?
        usernameField.attributedPlaceholder = NSAttributedString(string: usernameField.placeholder!, attributes: [NSForegroundColorAttributeName : UIColor.gray, NSFontAttributeName: UIFont.systemFont(ofSize: 20)])
        passwordField.attributedPlaceholder = NSAttributedString(string: passwordField.placeholder!, attributes: [NSForegroundColorAttributeName : UIColor.gray, NSFontAttributeName: UIFont.systemFont(ofSize: 20)])
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
    
    @IBAction func performLogin(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Account")
        fetchRequest.predicate = NSPredicate(format: "username == %@", usernameField.text!)
        var fetchedResults:[NSManagedObject]? = nil
        
        do {
            try fetchedResults = managedContext.fetch(fetchRequest) as? [NSManagedObject]
        }
        catch {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        
        if let results = fetchedResults {
            accounts = results
        } else {
            print("Could Not Fetch")
        }
        
        if accounts.count == 0 {
            let alert = UIAlertController(title:"Invalid Username", message:"Username does not exist.", preferredStyle:UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title:"OK", style:UIAlertActionStyle.cancel))
            self.present(alert, animated:true)
        } else if accounts[0].value(forKey: "password") as! String == passwordField.text! {
            performSegue(withIdentifier: "loginSegue", sender: nil)
        } else {
            let alert = UIAlertController(title:"Invalid Password", message:"Please enter the correct password.", preferredStyle:UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title:"OK", style:UIAlertActionStyle.cancel))
            self.present(alert, animated:true)
        }
    }
    
    //    override func viewWillDisappear(_ animated: Bool) {
    //        self.navigationController?.setNavigationBarHidden(false, animated:true)
    //    }

    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? MainMenuViewController {
            destinationVC.username = usernameField.text!
        }
    }
}
