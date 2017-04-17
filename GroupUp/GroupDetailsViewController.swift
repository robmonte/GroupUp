//
//  GroupDetailsViewController.swift
//  GroupUp
//
//  Created by Robert Montefusco on 3/19/17.
//  Copyright © 2017 GroupUp. All rights reserved.
//

import UIKit
import CoreData

class GroupDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var membersTable: UITableView!
    @IBOutlet weak var etaLabel: UILabel!
    
    private var membersList = [String]()
    private var groups = [NSManagedObject]()
    public var groupName:String = ""
    private var locAddress = ""
    private var locETA = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        membersTable.delegate = self
        membersTable.dataSource = self
        groupNameLabel.text = groupName
        NotificationCenter.default.addObserver(self, selector: #selector(getETA(notification:)), name: NSNotification.Name(rawValue: "setRoute"), object: nil)
        setupMembersArray()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    private func setupMembersArray() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Group")
        fetchRequest.predicate = NSPredicate(format: "groupName == %@", groupName)
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
        
        let names:String? = groups[0].value(forKey: "groupMembers") as? String
        membersList = names!.components(separatedBy: ",")
    }
    
    func getETA(notification: Notification) {
        if let dict: Dictionary<String,Double> = notification.userInfo as? Dictionary<String,Double> {
            self.locETA = dict["ETA"] ?? 0.0
            
            let hours = floor(self.locETA/3600)
            let minutes = floor((self.locETA - hours*3600)/60)
            let seconds = self.locETA - hours*3600 - minutes*60
            
            if Int(hours) > 0 {
                self.etaLabel.text? = "\(Int(hours)) hr \(Int(minutes)) min"
            }
            else if Int(minutes) > 4 {
                self.etaLabel.text? = "\(Int(minutes)) min"
            }
            else {
                self.etaLabel.text? = "\(Int(minutes)) min \(Int(seconds)) sec"
            }
        }
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
