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
import MapKit
import UserNotifications

class GroupDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var membersTable: UITableView!
    @IBOutlet weak var timeToLeaveLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var destTimeLabel: UILabel!
    
    private var membersList = [String]()
    private var groups = [NSManagedObject]()
    private var locAddress = ""
    private var destLat:Double = 0.0
    private var destLong:Double = 0.0
    private var destETA = 0.0
    private var destHours = 0
    private var destMinutes = 0
    
    public var groupName:String = ""
    
    weak var timer: Timer?
    
    func startTimer() {
        print("Notification every 60*\(SettingsViewController.refreshRate) seconds")
        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(60 * SettingsViewController.refreshRate), repeats: true) { [weak self] _ in
            
            let request = MKDirectionsRequest()
            let destCoordinates = CLLocationCoordinate2DMake((self?.destLat)!, (self?.destLong)!)
            let currMapItem = MKMapItem.forCurrentLocation()
            let destPlacemark = MKPlacemark(coordinate: destCoordinates)
            let destMapItem = MKMapItem(placemark: destPlacemark)
            
            request.source = currMapItem
            request.destination = destMapItem
            request.transportType = MKDirectionsTransportType.automobile
            request.requestsAlternateRoutes = false
            
            let directions = MKDirections(request: request)
            directions.calculate(completionHandler: { response, error in
                if let route = response?.routes.first {
                    print("ETA in timer: \(route.expectedTravelTime)")
                    
                    let eta = route.expectedTravelTime
                    
                    let date = Date()
                    let cal = Calendar.current
                    let hours = cal.component(.hour, from: date)
                    let minutes = cal.component(.minute, from: date)
                    let seconds = cal.component(.second, from: date)
                    
                    let currSeconds:Double = Double((hours*3600) + (minutes*60) + seconds)
                    let destTimeSeconds:Double = Double(((self?.destHours)!*3600) + ((self?.destMinutes)!*60))
                    
                    print("current time: \(hours):\(minutes):\(seconds)")
                    print("current time in seconds: \(currSeconds)")
                    print("curr time + eta seconds: \(currSeconds+eta)")
                    print("curr time + eta + 60*refresh rate: \(currSeconds + eta + Double(60*SettingsViewController.refreshRate))")
                    print("dest time in seconds \(destTimeSeconds)")
                    
                    
                    if ((currSeconds + eta + Double(60*SettingsViewController.refreshRate)) >= destTimeSeconds && currSeconds < destTimeSeconds) {
                        print("Setting notification for \(hours):\(minutes+1)")
                        
                        let center = UNUserNotificationCenter.current()
                        var notifyComponents = DateComponents()
                        
                        notifyComponents.hour = hours
                        notifyComponents.minute = minutes + 2 - (60*SettingsViewController.refreshRate)
                        
                        let trigger = UNCalendarNotificationTrigger(dateMatching: notifyComponents, repeats: false)
                        let content = UNMutableNotificationContent()
                        
                        content.title = "Time to leave!"
                        content.body = "It's time to head out! It is now the optimal time to leave to arrive at the desired time."
                        content.categoryIdentifier = "groupUpTTL"
                        content.sound = UNNotificationSound.default()
                        
                        let request = UNNotificationRequest(identifier: "groupUpTTL", content: content, trigger: trigger)
                        
                        center.add(request)
                        
                        self?.stopTimer()
                    }
                }
            })
            
            
            
//            let center = UNUserNotificationCenter.current()
//            var timeComponents = DateComponents()
//            
//            let hours = floor((self?.destETA)!/3600)
//            let minutes = floor(((self?.destETA)! - hours*3600)/60)
//            
//            var dateHour = (self?.destHours)! - Int(hours)
//            var dateMin = (self?.destMinutes)! - Int(minutes)
//
//            if(dateMin < 0) {
//                dateHour -= 1
//                dateMin = 60 - dateMin
//            }
//            if(dateHour < 0) {
//                dateHour = 23
//            }
//            
//            timeComponents.hour = dateHour
//            timeComponents.minute = dateMin
//            
//            print("notification scheduled for \(dateHour):\(dateMin)")
//            
//            let trigger = UNCalendarNotificationTrigger(dateMatching: timeComponents, repeats: false)
//            let content = UNMutableNotificationContent()
//            
//            content.title = "Time to leave!"
//            content.body = "It's time to head out! It is now the optimal time to leave to arrive at the desired time."
//            content.categoryIdentifier = "groupUpTTL"
//            content.sound = UNNotificationSound.default()
//            
//            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
//            
//            center.add(request)
            
//            let notification = UILocalNotification()
//            notification.alertBody = "It's Time to Leave!"
//            let curDate = NSDate()
//            let unitFlags: Set<Calendar.Component> = [.hour, .day, .month, .year]
//            var components = NSCalendar.current.dateComponents(unitFlags, from: curDate as Date)
//            
//            let hours = floor((self?.destETA)!/3600)
//            let minutes = floor(((self?.destETA)! - hours*3600)/60)
//            print("eta in notification is \(hours):\(minutes)")
//            var dateHour = (self?.destHours)! - Int(hours)
//            var dateMin = (self?.destMinutes)! - Int(minutes)
//            
//            if(dateMin < 0) {
//                dateHour -= 1
//                dateMin = 60 - dateMin
//            }
//            if(dateHour < 0) {
//                dateHour = 23
//            }
//            components.hour = dateHour
//            components.minute = dateMin
//            print("Setting notification for \(dateHour%12):\(dateMin)")
//            let dateTime = NSCalendar.current.date(from: components)
//            notification.fireDate = dateTime
//            notification.soundName = UILocalNotificationDefaultSoundName
//            UIApplication.shared.scheduleLocalNotification(notification)
            
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
    }
    
    // if appropriate, make sure to stop your timer in `deinit`
    deinit {
        stopTimer()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        membersTable.delegate = self
        membersTable.dataSource = self
        
        groupNameLabel.text = groupName
        print("locAddress is \(locAddress)")
        addressLabel.text? = locAddress
        
        //setupMembersArray()
        
        
        let rootRef = FIRDatabase.database().reference()
        let groupsRef = rootRef.child("Groups")
        let group = groupsRef.child(groupName)
        
        group.observe(.value, with: { snapshot in
            let userGroup = snapshot.value as? NSDictionary
            let users = userGroup?.allKeys as? [String]
            let leader = userGroup?.value(forKey: "_@+Leader**") as? String
            
            self.membersList.append(leader!)
            self.addressLabel.text = userGroup?.value(forKey: "_@+Address**") as? String
            self.destHours = (userGroup?.value(forKey: "_@+Hours**") as? Int)!
            self.destMinutes = (userGroup?.value(forKey: "_@+Minutes**") as? Int)!
            self.destLat = (userGroup?.value(forKey: "_@+Latitude**") as? Double)!
            self.destLong = (userGroup?.value(forKey: "_@+Longitude**") as? Double)!
            print(users!)
            
            for user in users! {
                if user.characters.first != "_" && user != leader! {
                    self.membersList.append(user)
                }
            }
            
            DispatchQueue.main.async {
                self.membersTable.reloadData()
            }
            
            let hours = self.destHours
            let minutes = self.destMinutes
            let minutesLeadingZero = String(format: "%02d", minutes)
            print(hours)
            print(minutes)
            var hours12 = hours % 12
            var amPm = ""
            
            if hours >= 0 && hours < 12{
                amPm = " AM"
            }
            else {
                amPm = " PM"
            }
            
            if hours12 == 0 {
                hours12 = 12
            }
            self.destTimeLabel.text = "\(hours12):\(minutesLeadingZero)" + amPm
            
            print("address before replace:")
            print(self.addressLabel.text!)
            let address = self.addressLabel.text!.replacingOccurrences(of: "\n", with: " ")
            print("after")
            print(address)
            
            print("lat: \(self.destLat), long: \(self.destLong)")
            
            let request = MKDirectionsRequest()
            let destCoordinates = CLLocationCoordinate2DMake(self.destLat, self.destLong)
            let currMapItem = MKMapItem.forCurrentLocation()
            let destPlacemark = MKPlacemark(coordinate: destCoordinates)
            let destMapItem = MKMapItem(placemark: destPlacemark)
            
            request.source = currMapItem
            request.destination = destMapItem
            request.transportType = MKDirectionsTransportType.automobile
            request.requestsAlternateRoutes = false
            
            let directions = MKDirections(request: request)
            directions.calculate(completionHandler: { response, error in
                if let route = response?.routes.first {
                    print("ETA: \(route.expectedTravelTime)")
                    
                    let eta = route.expectedTravelTime
                    let etaHours = floor(eta / 3600)
                    let etaMinutes = floor((eta - etaHours*3600) / 60)
                    self.destETA = eta
                    
                    let calcMin = minutes - Int(etaMinutes)
                    let calcHours = hours - Int(etaHours)
                    var calcHours12 = calcHours % 12
                    
                    if calcHours >= 0 && calcHours < 12{
                        amPm = " AM"
                    }
                    else {
                        amPm = " PM"
                    }
                    
                    if calcHours12 == 0 {
                        calcHours12 = 12
                    }
                    else if calcHours12 < 0 {
                        calcHours12 = 12 + calcHours12
                    }
                    
                    if calcMin < 0 {
                        let minLeading = String(format: "%02d", 60 + minutes - Int(etaMinutes))
                        self.timeToLeaveLabel.text = "\(calcHours12 - 1):\(minLeading)" + amPm
                    }
                    else {
                        let minLeading = String(format: "%02d", minutes - Int(etaMinutes))
                        self.timeToLeaveLabel.text = "\(calcHours12):\(minLeading)" + amPm
                    }
                    
                    self.startTimer()
                }
                else {
                    print("Error getting ETA")
                }
                
            })
        })
        
        
        
        
    // This version gets the location coordinates of the destination from the address
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        membersTable.delegate = self
//        membersTable.dataSource = self
//        
//        groupNameLabel.text = groupName
//        print("locAddress is \(locAddress)")
//        addressLabel.text? = locAddress
//        
//        //setupMembersArray()
//        
//        
//        let rootRef = FIRDatabase.database().reference()
//        let groupsRef = rootRef.child("Groups")
//        let group = groupsRef.child(groupName)
//        
//        group.observe(.value, with: { snapshot in
//            let userGroup = snapshot.value as? NSDictionary
//            let users = userGroup?.allKeys as? [String]
//            let leader = userGroup?.value(forKey: "_@+Leader**") as? String
//            
//            self.membersList.append(leader!)
//            self.addressLabel.text = userGroup?.value(forKey: "_@+Address**") as? String
//            self.destHours = (userGroup?.value(forKey: "_@+Hours**") as? Int)!
//            self.destMinutes = (userGroup?.value(forKey: "_@+Minutes**") as? Int)!
//            self.destLat = (userGroup?.value(forKey: "_@+Latitude**") as? Double)!
//            self.destLong = (userGroup?.value(forKey: "_@+Longitude**") as? Double)!
//            print(users!)
//            
//            for user in users! {
//                if user.characters.first != "_" && user != leader! {
//                    self.membersList.append(user)
//                }
//            }
//            
//            DispatchQueue.main.async {
//                self.membersTable.reloadData()
//            }
//            
//            let hours = self.destHours
//            let minutes = self.destMinutes
//            let minutesLeadingZero = String(format: "%02d", minutes)
//            print(hours)
//            print(minutes)
//            var hours12 = hours % 12
//            var amPm = ""
//            
//            if hours >= 0 && hours < 12{
//                amPm = " AM"
//            }
//            else {
//                amPm = " PM"
//            }
//            
//            if hours12 == 0 {
//                hours12 = 12
//            }
//            self.destTimeLabel.text = "\(hours12):\(minutesLeadingZero)" + amPm
//            
//            print("address before replace:")
//            print(self.addressLabel.text!)
//            let address = self.addressLabel.text!.replacingOccurrences(of: "\n", with: " ")
//            print("after")
//            print(address)
//            
//            LocationManager.sharedInstance.getReverseGeoCodedLocation(address: address, completionHandler: { (location:CLLocation?, placemark:CLPlacemark?, error:NSError?) in
//                
//                if error != nil {
//                    print((error?.localizedDescription)!)
//                    return
//                }
//                
//                if placemark == nil {
//                    print("Location can't be fetched")
//                    return
//                }
//                
//                let destLat = placemark?.location?.coordinate.latitude
//                let destLong = placemark?.location?.coordinate.longitude
//                print("lat: \(destLat!), long: \(destLong!)")
//                
//                let request = MKDirectionsRequest()
//                let destCoordinates = CLLocationCoordinate2DMake(destLat!, destLong!)
//                let currMapItem = MKMapItem.forCurrentLocation()
//                let destPlacemark = MKPlacemark(coordinate: destCoordinates)
//                let destMapItem = MKMapItem(placemark: destPlacemark)
//                
//                request.source = currMapItem
//                request.destination = destMapItem
//                request.transportType = MKDirectionsTransportType.automobile
//                request.requestsAlternateRoutes = false
//                
//                let directions = MKDirections(request: request)
//                directions.calculate(completionHandler: { response, error in
//                    if let route = response?.routes.first {
//                        print("ETA: \(route.expectedTravelTime)")
//                        
//                        let eta = route.expectedTravelTime
//                        let etaHours = floor(eta / 3600)
//                        let etaMinutes = floor((eta - etaHours*3600) / 60)
//                        self.destETA = eta
//                        
//                        let calcMin = minutes - Int(etaMinutes)
//                        let calcHours = hours - Int(etaHours)
//                        var calcHours12 = calcHours % 12
//                        
//                        if calcHours >= 0 && calcHours < 12{
//                            amPm = " AM"
//                        }
//                        else {
//                            amPm = " PM"
//                        }
//                        
//                        if calcHours12 == 0 {
//                            calcHours12 = 12
//                        }
//                        else if calcHours12 < 0 {
//                            calcHours12 = 12 + calcHours12
//                        }
//                        
//                        if calcMin < 0 {
//                            let minLeading = String(format: "%02d", 60 + minutes - Int(etaMinutes))
//                            self.timeToLeaveLabel.text = "\(calcHours12 - 1):\(minLeading)" + amPm
//                        }
//                        else {
//                            let minLeading = String(format: "%02d", minutes - Int(etaMinutes))
//                            self.timeToLeaveLabel.text = "\(calcHours12):\(minLeading)" + amPm
//                        }
//                        
//                        self.startTimer()
//                    }
//                    else {
//                        print("Error getting ETA")
//                    }
//                })
//                
//            })
//        })
    
        
//        let geocoder = CLGeocoder()
//        geocoder.geocodeAddressString("2800 Guadalupe St Austin, TX 78705") { (placemarks, error) in
//            let placemark = placemarks?.first
//            let destLat = placemark?.location?.coordinate.latitude
//            let destLong = placemark?.location?.coordinate.longitude
//            print("lat: \(destLat)")
//            print("long: \(destLong)")
//            let destCoordinates = CLLocationCoordinate2DMake(destLat!, destLong!)
//            
//            let request = MKDirectionsRequest()
//            let currMapItem = MKMapItem.forCurrentLocation()
//            let destPlacemark = MKPlacemark(coordinate: destCoordinates)
//            let destMapItem = MKMapItem(placemark: destPlacemark)
//            
//            request.source = currMapItem
//            request.destination = destMapItem
//            request.transportType = MKDirectionsTransportType.automobile
//            request.requestsAlternateRoutes = false
//            
//            let directions = MKDirections(request: request)
//            directions.calculate(completionHandler: { response, error in
//                if let route = response?.routes.first {
//                    print("ETA: \(route.expectedTravelTime)")
//                }
//                else {
//                    print("Error getting ETA")
//                }
//            })
//        }
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
//            timeToLeaveLabel.text = "\(calcHours):\(minLeading)"
//        }
//        else {
//            let minLeading = String(format: "%02d", minutes-Int(etaMinutes))
//            timeToLeaveLabel.text = "\(calcHours):\(minLeading)"
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
    
//    private func setupMembersArray() {
//        let rootRef = FIRDatabase.database().reference()
//        let groupsRef = rootRef.child("Groups")
//        let group = groupsRef.child(groupName)
//        
//        group.observe(.value, with: { snapshot in
//            let userGroup = snapshot.value as? NSDictionary
//            let users = userGroup?.allKeys as? [String]
//            let leader = userGroup?.value(forKey: "_@+Leader**") as? String
//            
//            self.membersList.append(leader!)
//            self.addressLabel.text = userGroup?.value(forKey: "_@+Address**") as? String
//            self.destHours = (userGroup?.value(forKey: "_@+Hours**") as? Int)!
//            self.destMinutes = (userGroup?.value(forKey: "_@+Minutes**") as? Int)!
//            self.destTimeLabel.text = "\(self.destHours%12):\(self.destMinutes)"
//            print(users!)
//
//            for user in users! {
//                if user.characters.first != "_" && user != leader! {
//                    self.membersList.append(user)
//                }
//            }
//            
//            DispatchQueue.main.async {
//                self.membersTable.reloadData()
//            }
//        })
//    }
    
//    func getETA(notification: Notification) {
//        if let dict: Dictionary<String,Any> = notification.userInfo as? Dictionary<String,Any> {
//            self.destETA = dict["ETA"] as! Double
//            self.locAddress = dict["Address"] as! String
//            self.addressLabel.text? = self.locAddress
//            
//            let appDelegate = UIApplication.shared.delegate as! AppDelegate
//            let managedContext = appDelegate.persistentContainer.viewContext
//            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Group")
//            fetchRequest.predicate = NSPredicate(format: "groupName == %@", groupName)
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
//                groups = results
//            } else {
//                print("Could not fetch")
//            }
//            groups[0].setValue(self.locAddress, forKey: "address")
//            groups[0].setValue(self.destETA, forKey: "eta")
//        
//            do {
//                try managedContext.save()
//            }
//            catch {
//                let nserror = error as NSError
//                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
//                abort()
//            }
//            
//            let destHours:Int = groups[0].value(forKey: "timeHours") as! Int
//            let destMinutes:Int = groups[0].value(forKey: "timeMinutes") as! Int
//            
//            
//            let hours = floor(self.destETA/3600)
//            let minutes = floor((self.destETA - hours*3600)/60)
////            let seconds = self.locETA - hours*3600 - minutes*60
//            
//            let notification = UILocalNotification()
//            notification.alertBody = "It's Time to Leave!"
//            let curDate = NSDate()
//            let unitFlags: Set<Calendar.Component> = [.hour, .day, .month, .year]
//            var components = NSCalendar.current.dateComponents(unitFlags, from: curDate as Date)
//            var dateHour = destHours - Int(hours)
//            var dateMin = destMinutes - Int(minutes)
//            if(dateMin < 0) {
//                dateHour -= 1
//                dateMin = 60 - dateMin
//            }
//            if(dateHour < 0) {
//                dateHour = 23
//            }
//            components.hour = dateHour
//            components.minute = dateMin
//            let dateTime = NSCalendar.current.date(from: components)
//            notification.fireDate = dateTime
//            notification.soundName = UILocalNotificationDefaultSoundName
//            UIApplication.shared.scheduleLocalNotification(notification)
//        }
//    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
