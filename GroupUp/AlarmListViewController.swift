//
//  AlarmListViewController.swift
//  GroupUp
//
//  Created by Robert Montefusco on 3/19/17.
//  Copyright © 2017 GroupUp. All rights reserved.
//

import UIKit
import UserNotifications

protocol AlarmCellDelegate {
    func didChangeSwitchState(_ sender: AlarmTableViewCell, isOn: Bool)
}

class Alarm: NSObject, NSCoding {
    
    var groupName:String = globalGroup
    var time:Double = 0
    var hour:Int = 0
    var minute:Int = 0
    var name:String = ""
    var descript:String = ""
    var active:Bool = true
    var uuid:String = ""
    
    init(h:Int, m:Int, t:Double, n:String, d:String) {
        self.hour = h
        self.minute = m
        self.time = t
        self.name = n
        self.descript = d
        self.uuid = UUID().uuidString
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.groupName = aDecoder.decodeObject(forKey: "groupName") as? String ?? ""
        self.hour = Int(aDecoder.decodeInt32(forKey: "hour"))
        self.minute = Int(aDecoder.decodeInt32(forKey: "minute"))
        self.time = aDecoder.decodeDouble(forKey: "time")
        self.name = aDecoder.decodeObject(forKey: "name") as? String ?? ""
        self.descript = aDecoder.decodeObject(forKey: "descript") as? String ?? ""
        self.uuid = aDecoder.decodeObject(forKey: "uuid") as? String ?? ""
        self.active = aDecoder.decodeBool(forKey: "active")
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(groupName, forKey: "groupName")
        aCoder.encode(hour, forKey: "hour")
        aCoder.encode(minute, forKey: "minute")
        aCoder.encode(time, forKey: "time")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(descript, forKey: "descript")
        aCoder.encode(uuid, forKey: "uuid")
        aCoder.encode(active, forKey: "active")
    }
}

func saveAlarms() {
    let alarmSave = AlarmListViewController.alarmList
    
    let alarmData = NSKeyedArchiver.archivedData(withRootObject: alarmSave)
    print("saving alarms with key \(globalGroup)")
    UserDefaults.standard.set(alarmData, forKey: globalGroup)
}

func loadAlarms(passedGroup: String) {
    print("loading alarms with key \(passedGroup)")
    guard let alarmData = UserDefaults.standard.object(forKey: passedGroup) as? NSData else {
        print("'\(passedGroup)' not found in UserDefaults")
        AlarmListViewController.alarmList = [Alarm]()
        return
    }
    
    guard let alarmArray = NSKeyedUnarchiver.unarchiveObject(with: alarmData as Data) as? [Alarm] else {
        print("Could not unarchive from alarmData")
        return
    }
    
    for alarm in alarmArray {
        print("alarm.groupName: \(alarm.groupName)")
        print("alarm.hour: \(alarm.hour)")
        print("alarm.minute: \(alarm.minute)")
        print("alarm.time: \(alarm.time)")
        print("alarm.name: \(alarm.name)")
        print("alarm.descript: \(alarm.descript)")
        print("alarm.uuid: \(alarm.uuid)")
        print("alarm.active: \(alarm.active)")
        print()
    }
    
    AlarmListViewController.alarmList = alarmArray
}

public var globalGroup:String = ""

class AlarmListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NewAlarmDelegate, AlarmCellDelegate {
    
    @IBOutlet weak var alarmsTable: UITableView!
    
    public static var alarmList = [Alarm]()
    public var group:String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Alarm List"
        
        globalGroup = group
        
        alarmsTable.delegate = self
        alarmsTable.dataSource = self
    }
    
    func addAlarmNotification() {
        
    }
    
    func addAlarmList(alarm: Alarm) {
        print("IN DELEGATE!")
        print(alarm.name)
        print(alarm.descript)
        print(alarm.uuid)
        AlarmListViewController.alarmList.append(alarm)
        
        DispatchQueue.main.async {
            self.alarmsTable.reloadData()
        }
        saveAlarms()
    }
    
    func didChangeSwitchState(_ sender: AlarmTableViewCell, isOn: Bool) {
        let indexPath = self.alarmsTable.indexPath(for: sender)
        
        print("state changed at \(String(describing: indexPath?.row))")
        
        AlarmListViewController.alarmList[(indexPath?.row)!].active = isOn
        saveAlarms()
        
        if (isOn == false) {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [AlarmListViewController.alarmList[(indexPath?.row)!].uuid])
        }
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
        return AlarmListViewController.alarmList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "alarmsID", for: indexPath) as! AlarmTableViewCell
        
        cell.nameLabel?.text = AlarmListViewController.alarmList[indexPath.row].name
        let hour = String(format: "%02d", AlarmListViewController.alarmList[indexPath.row].hour % 12)
        let minute = String(format: "%02d", AlarmListViewController.alarmList[indexPath.row].minute)
        cell.timeLabel?.text = "\(hour):\(minute)"
        cell.toggle.isOn = AlarmListViewController.alarmList[indexPath.row].active
        cell.layer.backgroundColor = self.view.backgroundColor?.cgColor
        cell.cellDelegate = self
        
        return cell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated:true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let destinationVC = segue.destination as? NewAlarmViewController {
            destinationVC.delegate = self
        }
    }
}
