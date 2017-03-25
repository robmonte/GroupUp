//
//  CreateAccountViewController.swift
//  GroupUp
//
//  Created by Michael McCrory on 3/20/17.
//  Copyright © 2017 GroupUp. All rights reserved.
//

import UIKit
import CoreData

class CreateAccountViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameField: CreateAccountTextField!
    @IBOutlet weak var firstField: CreateAccountTextField!
    @IBOutlet weak var lastField: CreateAccountTextField!
    @IBOutlet weak var passwordField: CreateAccountTextField!
    @IBOutlet weak var confirmField: CreateAccountTextField!
    
    @IBOutlet weak var createButton: UIButton!
    
    private var accounts = [NSManagedObject]()
    
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
    
    @IBAction func saveAccountCore(_ sender: Any) {
        if firstField.text! == "" || lastField.text! == "" || passwordField.text! == "" || confirmField.text! == "" || usernameField.text! == "" {
            let alert = UIAlertController(title:"Invalid input", message:"You must enter a value for all fields.", preferredStyle:UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title:"OK", style:UIAlertActionStyle.cancel))
            self.present(alert, animated:true)
        }
        else if passwordField.text!.characters.count < 8 {
            let alert = UIAlertController(title:"Weak Password", message:"Password must be at least 8 characters long.", preferredStyle:UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title:"OK", style:UIAlertActionStyle.cancel))
            self.present(alert, animated:true)
        }
        else if passwordField.text! != confirmField.text! {
            let alert = UIAlertController(title:"Invalid input", message:"Passwords do not match.", preferredStyle:UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title:"OK", style:UIAlertActionStyle.cancel))
            self.present(alert, animated:true)
        }
        else if checkDuplicateUsername() != 0 {
            let alert = UIAlertController(title:"Invalid input", message:"Username already exists.", preferredStyle:UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title:"OK", style:UIAlertActionStyle.cancel))
            self.present(alert, animated:true)
        }
        else {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let managedContext = appDelegate.persistentContainer.viewContext
            let entity =  NSEntityDescription.entity(forEntityName: "Account", in: managedContext)
            let candidate = NSManagedObject(entity:entity!, insertInto:managedContext)
            
            candidate.setValue(usernameField.text!, forKey:"username")
            candidate.setValue(firstField.text!, forKey:"firstName")
            candidate.setValue(lastField.text!, forKey:"lastName")
            candidate.setValue(passwordField.text!, forKey:"password")
            
            do {
                try managedContext.save()
            }
            catch {
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
            
            _ = navigationController?.popViewController(animated:true)
        }
    }
    
    func checkDuplicateUsername() -> Int {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Account")
        fetchRequest.predicate = NSPredicate(format: "username == %@", usernameField.text!)
        var fetchedResults:[NSManagedObject]? = nil
        
        do {
            print("trying")
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
            print("Could not fetch")
        }
        
        return accounts.count
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
