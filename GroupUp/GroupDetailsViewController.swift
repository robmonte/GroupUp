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
    @IBOutlet weak var openAddressButton: UIButton!
    @IBOutlet weak var setAlarmButton: UIButton!
    
    private var membersList = [String]()
    private var firstList = [String]()
    private var groups = [NSManagedObject]()
    private var locAddress = ""
    private var leader = ""
    private var leaderFirst = ""
    private var destLat:Double = 0.0
    private var destLong:Double = 0.0
    private var destETA = 0.0
    private var destHours = 0
    private var destMinutes = 0
    
    public var groupName:String = ""
    
    private var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Group Details"
        
        membersTable.delegate = self
        membersTable.dataSource = self
        
        openAddressButton.layer.borderWidth = 1.0
        openAddressButton.layer.borderColor = UIColor(hex: 0x007AFF, alpha: 1.0).cgColor
        openAddressButton.layer.cornerRadius = 5
        
        setAlarmButton.layer.borderWidth = 1.0
        setAlarmButton.layer.borderColor = UIColor(hex: 0x007AFF, alpha: 1.0).cgColor
        setAlarmButton.layer.cornerRadius = 5
        
        groupNameLabel.text = groupName
        print("locAddress is \(locAddress)")
        addressLabel.text? = locAddress
        loadAlarms(passedGroup: groupName)
        
        let rootRef = FIRDatabase.database().reference()
        let groupsRef = rootRef.child("Groups")
        let group = groupsRef.child(groupName)
        
        group.observe(.value, with: { snapshot in
            let userGroup = snapshot.value as? NSDictionary
            let users = userGroup?.allKeys as? [String]
            
            self.leader = (userGroup?.value(forKey: "_@+Leader**") as? String)!
            self.addressLabel.text = userGroup?.value(forKey: "_@+Address**") as? String
            self.destHours = (userGroup?.value(forKey: "_@+Hours**") as? Int)!
            self.destMinutes = (userGroup?.value(forKey: "_@+Minutes**") as? Int)!
            self.destLat = (userGroup?.value(forKey: "_@+Latitude**") as? Double)!
            self.destLong = (userGroup?.value(forKey: "_@+Longitude**") as? Double)!
            
            self.membersList.append(self.leader)
            print(users!)
            
            for user in users! {
                if user.characters.first != "_" && user != self.leader {
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
            
            let rootRef = FIRDatabase.database().reference()
            let groupsRef = rootRef.child("Accounts")
            
            for user in users! {
                if user.characters.first != "_" {
                    let userRef = groupsRef.child(user)
                    userRef.observe(.value, with: { snapshotFirst in
                        let userInfo = snapshotFirst.value as? NSDictionary
                        let first = userInfo?["First"]
                        
                        if (self.leader == user) {
                            self.leaderFirst = first as! String
                        }
                        else {
                            self.firstList.append(first as! String)
                        }
                        print(self.firstList)
                        DispatchQueue.main.async {
                            self.membersTable.reloadData()
                        }
                    })
                }
            }
        })
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
        cell.backgroundColor = self.view.backgroundColor
        
        if indexPath.row == 0 {
            if firstList.count > indexPath.row {
                cell.textLabel?.text = "Leader: " + leaderFirst
            }
            else {
                cell.textLabel?.text = "Leader: " + leader
            }
        }
        else {
            if firstList.count >= indexPath.row {
                cell.textLabel?.text = firstList[indexPath.row-1]
            }
            else {
                cell.textLabel?.text = membersList[indexPath.row]
            }
        }
        
        return cell
    }
    
    func startTimer() {
        print("Notification every 60*\(SettingsViewController.refreshRate) seconds")
        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(60 * SettingsViewController.refreshRate), repeats: true) { [weak self] _ in
            print("starting timer")
            
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
                    
                    print("current time in seconds: \(currSeconds)")
                    print("curr time + eta + 60*refresh rate: \(currSeconds + eta + Double(60*SettingsViewController.refreshRate))")
                    print("dest time in seconds \(destTimeSeconds)\n")
                    
                    for alarm in AlarmListViewController.alarmList {
                        print("curr time + eta + alarm.time + 60*refresh rate: \(currSeconds + eta + alarm.time + Double(60*SettingsViewController.refreshRate))")
                        print("alarm time for \(alarm.time) which is \(alarm.hour):\(alarm.minute) before\n")
                        if (alarm.active && ((currSeconds + eta + alarm.time + Double(60*SettingsViewController.refreshRate)) >= destTimeSeconds) && (currSeconds < destTimeSeconds)) {
                            
                            let center = UNUserNotificationCenter.current()
                            var notifyComponents = DateComponents()
                            
                            notifyComponents.hour = hours
                            notifyComponents.minute = minutes + 2 - SettingsViewController.refreshRate
                            
                            print("\t\nsetting alarm for \(alarm.name) at \(hours):\(minutes+2 - SettingsViewController.refreshRate)\n")
                            
                            let trigger = UNCalendarNotificationTrigger(dateMatching: notifyComponents, repeats: false)
                            let content = UNMutableNotificationContent()
                            
                            content.title = alarm.name
                            content.body = alarm.descript
                            content.categoryIdentifier = alarm.uuid
                            content.sound = UNNotificationSound.default()
                            
                            let request = UNNotificationRequest(identifier: alarm.uuid, content: content, trigger: trigger)
                            
                            center.add(request)
                            
                            alarm.active = false
                        }
                    }
                    
                    if ((currSeconds + eta + Double(60*SettingsViewController.refreshRate)) >= destTimeSeconds && currSeconds < destTimeSeconds) {
                        print("\t\nSetting notification for TTL at \(hours):\(minutes+2 - SettingsViewController.refreshRate)\n")
                        
                        let center = UNUserNotificationCenter.current()
                        var notifyComponents = DateComponents()
                        
                        notifyComponents.hour = hours
                        notifyComponents.minute = minutes + 2 - SettingsViewController.refreshRate
                        
                        let trigger = UNCalendarNotificationTrigger(dateMatching: notifyComponents, repeats: false)
                        let content = UNMutableNotificationContent()
                        
                        content.title = "Time to leave!"
                        content.body = "It's time to head out! It is now the optimal time to leave so you can arrive at the desired time."
                        content.categoryIdentifier = "groupUpTTL\(String(describing: self?.groupName))"
                        content.sound = UNNotificationSound.default()
                        
                        let request = UNNotificationRequest(identifier: "groupUpTTL\(String(describing: self?.groupName))", content: content, trigger: trigger)
                        
                        center.add(request)
                        
                        self?.stopTimer()
                    }
                }
            })
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
    }
    
    // if appropriate, make sure to stop your timer in `deinit`
    deinit {
        stopTimer()
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let destinationVC = segue.destination as? ViewDirectionsViewController {
            destinationVC.destLat = destLat
            destinationVC.destLong = destLong
        }
        if let destinationVC = segue.destination as? AlarmListViewController {
            destinationVC.group = groupName
        }
    }
}
