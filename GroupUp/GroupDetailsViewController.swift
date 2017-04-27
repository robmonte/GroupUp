//
//  GroupDetailsViewController.swift
//  GroupUp
//
//  Created by Robert Montefusco on 3/19/17.
//  Copyright © 2017 GroupUp. All rights reserved.
//

import UIKit
import CoreData
import Firebase

class GroupDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var membersTable: UITableView!
    @IBOutlet weak var etaLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var destTimeLabel: UILabel!
    
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
        addressLabel.text? = locAddress
        setupMembersArray()
        
        NotificationCenter.default.addObserver(self, selector: #selector(getETA(notification:)), name: NSNotification.Name(rawValue: "setRoute"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        let managedContext = appDelegate.persistentContainer.viewContext
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Group")
//        fetchRequest.predicate = NSPredicate(format: "groupName == %@", groupName)
//        var fetchedResults:[NSManagedObject]? = nil
//        
//        do {
//            try fetchedResults = managedContext.fetch(fetchRequest) as? [NSManagedObject]
//        }
//        catch {
//            let nserror = error as NSError
//            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
//            abort()
//        }
//        
//        if let results = fetchedResults {
//            groups = results
//        } else {
//            print("Could not fetch")
//        }
//        
//        let hours:Int = groups[0].value(forKey: "timeHours") as! Int
//        let minutes:Int = groups[0].value(forKey: "timeMinutes") as! Int
//        let minutesLeading = String(format: "%02d", minutes)
//        var hours12 = hours%12
//        if hours12 == 0 {
//            hours12 = 12
//        }
//        
//        destTimeLabel.text = "\(hours12):\(minutesLeading)"
//        
//        let eta = groups[0].value(forKey: "eta") as? Double
//        let etaHours = floor(eta!/3600)
//        let etaMinutes = floor((eta! - etaHours*3600)/60)
////        let etaSeconds = eta! - etaHours*3600 - etaMinutes*60
//        
//        let calcMin = minutes - Int(etaMinutes)
//        var calcHours = (hours - Int(etaHours)) % 12
//        if calcHours == 0 {
//            calcHours = 12
//        }
//        else if calcHours < 0 {
//            calcHours = 12 + calcHours
//        }
//        
//        if calcMin < 0 {
//            let minLeading = String(format: "%02d", 60+minutes-Int(etaMinutes))
//            etaLabel.text = "\(calcHours):\(minLeading)"
//        }
//        else {
//            let minLeading = String(format: "%02d", minutes-Int(etaMinutes))
//            etaLabel.text = "\(calcHours):\(minLeading)"
//        }
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
        let rootRef = FIRDatabase.database().reference()
        let groupsRef = rootRef.child("Groups")
        let group = groupsRef.child(groupName)
        
        group.observe(.value, with: { snapshot in
            let userGroup = snapshot.value as? NSDictionary
            let users = userGroup?.allKeys as? [String]
            print(users!)
            self.membersList = users!
            
            DispatchQueue.main.async {
                self.membersTable.reloadData()
            }
        })
        
        
        
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        let managedContext = appDelegate.persistentContainer.viewContext
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Group")
//        fetchRequest.predicate = NSPredicate(format: "groupName == %@", groupName)
//        var fetchedResults:[NSManagedObject]? = nil
//        
//        do {
//            try fetchedResults = managedContext.fetch(fetchRequest) as? [NSManagedObject]
//        }
//        catch {
//            let nserror = error as NSError
//            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
//            abort()
//        }
//        
//        if let results = fetchedResults {
//            groups = results
//        } else {
//            print("Could not fetch")
//        }
//        
//        if let eta = groups[0].value(forKey: "eta") as? Double {
//            self.locETA = eta
//        }
//        if let address = groups[0].value(forKey: "address") as? String {
//            self.locAddress = address
//        }
//        let names:String? = groups[0].value(forKey: "groupMembers") as? String
//        membersList = names!.components(separatedBy: ",")
    }
    
    func getETA(notification: Notification) {
        if let dict: Dictionary<String,Any> = notification.userInfo as? Dictionary<String,Any> {
            self.locETA = dict["ETA"] as! Double
            self.locAddress = dict["Address"] as! String
            self.addressLabel.text? = self.locAddress
            
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
            groups[0].setValue(self.locAddress, forKey: "address")
            groups[0].setValue(self.locETA, forKey: "eta")
        
            do {
                try managedContext.save()
            }
            catch {
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
            
            let destHours:Int = groups[0].value(forKey: "timeHours") as! Int
            let destMinutes:Int = groups[0].value(forKey: "timeMinutes") as! Int
            
            
            let hours = floor(self.locETA/3600)
            let minutes = floor((self.locETA - hours*3600)/60)
//            let seconds = self.locETA - hours*3600 - minutes*60
            
            let notification = UILocalNotification()
            notification.alertBody = "It's Time to Leave!"
            let curDate = NSDate()
            let unitFlags: Set<Calendar.Component> = [.hour, .day, .month, .year]
            var components = NSCalendar.current.dateComponents(unitFlags, from: curDate as Date)
            var dateHour = destHours - Int(hours)
            var dateMin = destMinutes - Int(minutes)
            if(dateMin < 0) {
                dateHour -= 1
                dateMin = 60 - dateMin
            }
            if(dateHour < 0) {
                dateHour = 23
            }
            components.hour = dateHour
            components.minute = dateMin
            let dateTime = NSCalendar.current.date(from: components)
            notification.fireDate = dateTime
            notification.soundName = UILocalNotificationDefaultSoundName
            UIApplication.shared.scheduleLocalNotification(notification)
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
