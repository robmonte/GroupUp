//
//  CreateGroupViewController.swift
//  GroupUp
//
//  Created by Robert Montefusco on 3/19/17.
//  Copyright © 2017 GroupUp. All rights reserved.
//

import UIKit
import CoreData
import Firebase

class CreateGroupViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var groupNameField: UITextField!
    @IBOutlet weak var membersTable: UITableView!
    
    public var username:String = ""
    private var addMembers:String = ""
    private var accounts = [NSManagedObject]()
    private var groups = [NSManagedObject]()
    private var membersList = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        groupNameField.delegate = self
        membersTable.delegate = self
        membersTable.dataSource = self
        addMembers = "\(username)"
        membersList.append(addMembers)
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated:true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return membersList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "membersID")
        
        if indexPath.row == 0 {
            cell.textLabel?.text = "Leader: " + membersList[indexPath.row]
        }
        else {
            cell.textLabel?.text = membersList[indexPath.row]
        }
        
        return cell
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func confirmCreationButton(_ sender: Any) {
        if groupNameField.text == "" {
            let alert = UIAlertController(title:"Invalid input", message:"Please enter a group name.", preferredStyle:UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title:"OK", style:UIAlertActionStyle.cancel))
            self.present(alert, animated:true)
        }
        else if checkDuplicateGroup() != 0 {
            let alert = UIAlertController(title:"Invalid input", message:"Group already exists.", preferredStyle:UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title:"OK", style:UIAlertActionStyle.cancel))
            self.present(alert, animated:true)
        }
        else {
            let rootRef = FIRDatabase.database().reference()
            let groupsRef = rootRef.child("Groups")
            let newRef = groupsRef.child(self.groupNameField.text!)
            //let groupData:[String: [String]] = ["Members": membersList]
            
            newRef.setValue(membersList)
            print(addMembers)
            print(membersList)
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let managedContext = appDelegate.persistentContainer.viewContext
            let entity =  NSEntityDescription.entity(forEntityName: "Group", in: managedContext)
            let group = NSManagedObject(entity:entity!, insertInto:managedContext)
            
            group.setValue(groupNameField.text!, forKey:"groupName")
            group.setValue(addMembers, forKey:"groupMembers")
            group.setValue(username, forKey:"groupLeader")
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

    @IBAction func addMemberButton(_ sender: Any) {
        let alert = UIAlertController(title:"Add to group", message:"Enter the username you wish to add", preferredStyle:UIAlertControllerStyle.alert)
        alert.addTextField {
            (addUserField: UITextField!) in
            addUserField.placeholder = "Enter username here"
        }
        alert.addAction(UIAlertAction(title:"Add", style:UIAlertActionStyle.default) {
            UIAlertAction in
            
            let addUserField = alert.textFields?[0]
            let user:String = (addUserField?.text)!
            
            
            
//            let appDelegate = UIApplication.shared.delegate as! AppDelegate
//            let managedContext = appDelegate.persistentContainer.viewContext
//            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Account")
//            fetchRequest.predicate = NSPredicate(format: "username == %@", user)
//            var fetchedResults:[NSManagedObject]? = nil
//            
//            do {
//                try fetchedResults = managedContext.fetch(fetchRequest) as? [NSManagedObject]
//            }
//            catch {
//                let nserror = error as NSError
//                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
//                abort()
//            }
//            
//            if let results = fetchedResults {
//                self.accounts = results
//            } else {
//                print("Could Not Fetch")
//            }
            
            
            var exists = false
            let rootRef = FIRDatabase.database().reference()
            rootRef.observe(.value, with: { snapshot in
                //print(snapshot.value)
                print ("checking if \(user) exists!!!")
                exists = snapshot.hasChild("Accounts/\(user)")
                print(exists)
                //print(snapshot.childSnapshot(forPath: "Accounts"))
                
                
                if !exists {
                    let noSuchUserAlert = UIAlertController(title:"Invalid input", message:"Username does not exist.", preferredStyle:UIAlertControllerStyle.alert)
                    noSuchUserAlert.addAction(UIKit.UIAlertAction(title:"OK", style:UIAlertActionStyle.cancel))
                    self.present(noSuchUserAlert, animated:true)
                }
                else {
                    if self.membersList.contains(user) {
                        let alreadyInGroupAlert = UIAlertController(title:"Invalid input", message:"Username is already a member of the group.", preferredStyle:UIAlertControllerStyle.alert)
                        alreadyInGroupAlert.addAction(UIKit.UIAlertAction(title:"OK", style:UIAlertActionStyle.cancel))
                        self.present(alreadyInGroupAlert, animated:true)
                    }
                    else {
                        self.addMembers += ",\(user)"
                        self.membersList.append("\(user)")
                        DispatchQueue.main.async {
                            self.membersTable.reloadData()
                        }
                        
                    }
                }
            })
            
            print("exists is \(exists)")
            
//            if self.accounts.count == 0 {
//            if !exists {
//                let noSuchUserAlert = UIAlertController(title:"Invalid input", message:"Username does not exist.", preferredStyle:UIAlertControllerStyle.alert)
//                noSuchUserAlert.addAction(UIKit.UIAlertAction(title:"OK", style:UIAlertActionStyle.cancel))
//                self.present(noSuchUserAlert, animated:true)
//            }
//            else {
//                if self.membersList.contains(user) {
//                    let alreadyInGroupAlert = UIAlertController(title:"Invalid input", message:"Username is already a member of the group.", preferredStyle:UIAlertControllerStyle.alert)
//                    alreadyInGroupAlert.addAction(UIKit.UIAlertAction(title:"OK", style:UIAlertActionStyle.cancel))
//                    self.present(alreadyInGroupAlert, animated:true)
//                }
//                else {
//                    self.addMembers += ",\(user)"
//                    self.membersList.append("\(user)")
//                    DispatchQueue.main.async {
//                        self.membersTable.reloadData()
//                    }
//                    
//                }
//            }
        })
        alert.addAction(UIAlertAction(title:"Cancel", style:UIAlertActionStyle.cancel))
        self.present(alert, animated:true)
    }
    
    func checkDuplicateGroup() -> Int {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Group")
        fetchRequest.predicate = NSPredicate(format: "groupName == %@", groupNameField.text!)
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
            groups = results
        } else {
            print("Could not fetch")
        }
        
        return groups.count
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
