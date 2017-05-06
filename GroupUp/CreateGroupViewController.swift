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
    @IBOutlet weak var destTimePicker: UIDatePicker!
    @IBOutlet weak var setDestButton: UIButton!
    
    public var confirmedUsername:Bool = false
    public var confirmedGroupname:Bool = false
    public var username:String = ""
    public var setAddress:String = ""
    public var destLat:Double = 0.0
    public var destLong:Double = 0.0
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
        
        self.title = "Create a Group"
        groupNameField.layer.borderColor = UIColor.gray.cgColor
        groupNameField.layer.borderWidth = 1.0
        groupNameField.layer.cornerRadius = 5
        groupNameField.attributedPlaceholder = NSAttributedString(string: groupNameField.placeholder!, attributes: [NSForegroundColorAttributeName : UIColor.gray])
        
        setDestButton.layer.borderWidth = 1.0
        setDestButton.layer.borderColor = UIColor(hex: 0x007AFF, alpha: 1.0).cgColor
        setDestButton.layer.cornerRadius = 5
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print(setAddress)
        
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
        cell.backgroundColor = self.view.backgroundColor
        
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
        else if setAddress == "" {
            let alert = UIAlertController(title:"Invalid input", message:"Please choose a destination from the map.", preferredStyle:UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title:"OK", style:UIAlertActionStyle.cancel))
            self.present(alert, animated:true)
        }
        else {
            let myRootRef = FIRDatabase.database().reference()
            var exists = false
            
            let date = destTimePicker.date
            let calendar = Calendar.current
            let timeComponents = calendar.dateComponents([.hour, .minute], from: date)
            
            myRootRef.observeSingleEvent(of: .value, with: { snapshot in
                print ("checking if group \(self.groupNameField.text!) exists!!!")
                exists = snapshot.hasChild("Groups/\(self.groupNameField.text!)")
                print(exists)
                
                if exists && !self.confirmedGroupname {
                    let alert = UIAlertController(title:"Invalid input", message:"Group already exists.", preferredStyle:UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title:"OK", style:UIAlertActionStyle.cancel))
                    self.present(alert, animated:true)
                }
                else {
                    let rootRef = FIRDatabase.database().reference()
                    let groupsRef = rootRef.child("Groups")
                    let newRef = groupsRef.child(self.groupNameField.text!)
                    
                    var membersDict = [String: Any]()
                    for mem in self.membersList {
                        membersDict[mem] = mem
                    }
                    membersDict["_@+Address**"] = self.setAddress
                    membersDict["_@+Latitude**"] = self.destLat
                    membersDict["_@+Longitude**"] = self.destLong
                    membersDict["_@+Leader**"] = self.username
                    membersDict["_@+Hours**"] = timeComponents.hour
                    membersDict["_@+Minutes**"] = timeComponents.minute
                    
                    print(membersDict)
                    newRef.setValue(membersDict)
                    print(self.membersList)

                    self.confirmedUsername = true
                    self.confirmedGroupname = true
                    _ = self.navigationController?.popViewController(animated:true)
                }
            })
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
 
            var exists = false
            let rootRef = FIRDatabase.database().reference()
            rootRef.observe(.value, with: { snapshot in
                print ("checking if \(user) exists!!!")
                exists = snapshot.hasChild("Accounts/\(user)")
                print(exists)
                
                if !exists {
                    let noSuchUserAlert = UIAlertController(title:"Invalid input", message:"Username does not exist.", preferredStyle:UIAlertControllerStyle.alert)
                    noSuchUserAlert.addAction(UIKit.UIAlertAction(title:"OK", style:UIAlertActionStyle.cancel))
                    self.present(noSuchUserAlert, animated:true)
                }
                else {
                    if self.membersList.contains(user) && !self.confirmedUsername {
                        let alreadyInGroupAlert = UIAlertController(title:"Invalid input", message:"Username is already a member of the group.", preferredStyle:UIAlertControllerStyle.alert)
                        alreadyInGroupAlert.addAction(UIKit.UIAlertAction(title:"OK", style:UIAlertActionStyle.cancel))
                        self.present(alreadyInGroupAlert, animated:true)
                    }
                    else if !self.confirmedUsername {
                        self.addMembers += ",\(user)"
                        self.membersList.append("\(user)")
                        DispatchQueue.main.async {
                            self.membersTable.reloadData()
                        }
                    }
                }
            })
        })
        alert.addAction(UIAlertAction(title:"Cancel", style:UIAlertActionStyle.cancel))
        self.present(alert, animated:true)
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem
    }
}
