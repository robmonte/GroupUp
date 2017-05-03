//
//  NewAlarmViewController.swift
//  GroupUp
//
//  Created by Robert Montefusco on 5/2/17.
//  Copyright © 2017 GroupUp. All rights reserved.
//

import UIKit

protocol NewAlarmDelegate {
    func addAlarmNotification()
    func addAlarmList(alarm: Alarm)
}

class NewAlarmViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var alarmPicker: UIDatePicker!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var confirmLabel: UILabel!
    @IBOutlet weak var nameField: UITextField!
    
    public var hour:Int = 0
    public var minute:Int = 0
    public var delegate: NewAlarmDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "New Alarm"
        
        descriptionText.delegate = self
        descriptionText.text = "Enter a notification message"
        descriptionText.textColor = UIColor.gray
        
        let date = Date()
        let calendar = Calendar.current
        let hours = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        var h:String = "hour"
        var m:String = "minute"
        hour = hours
        minute = minutes
        
        if (hours > 1) {
            h = "hours"
        }
        if (minutes > 1) {
            m = "minutes"
        }
        if (minutes == 0) {
            confirmLabel.text = "Set an alarm for \(hours) \(h) before your time to leave?"
        }
        else if (hours == 0) {
            confirmLabel.text = "Set an alarm for \(minutes) \(m) before your time to leave?"
        }
        else {
            confirmLabel.text = "Set an alarm for \(hours) \(h) and \(minutes) \(m) before your time to leave?"
        }
        
        nameField.layer.borderColor = UIColor.gray.cgColor
        nameField.layer.borderWidth = 1.0
        nameField.layer.cornerRadius = 5
        nameField.attributedPlaceholder = NSAttributedString(string: nameField.placeholder!, attributes: [NSForegroundColorAttributeName : UIColor.gray])
        
        descriptionText.layer.borderColor = UIColor.gray.cgColor
        descriptionText.layer.borderWidth = 1.0
        descriptionText.layer.cornerRadius = 5
        
        alarmPicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)

        // Do any additional setup after loading the view.
    }
    
    func dateChanged(_ sender: UIDatePicker) {
        let componenets = Calendar.current.dateComponents([.hour, .minute], from: sender.date)
        if let hr = componenets.hour, let min = componenets.minute {
            var h:String = "hour"
            var m:String = "minute"
            
            hour = hr
            minute = min
            if (hour > 1) {
                h = "hours"
            }
            if (minute > 1) {
                m = "minutes"
            }
            if (minute == 0) {
                confirmLabel.text = "Set an alarm for \(hour) \(h) before your time to leave?"
            }
            else if (hour == 0) {
                confirmLabel.text = "Set an alarm for \(minute) \(m) before your time to leave?"
            }
            else {
                confirmLabel.text = "Set an alarm for \(hour) \(h) and \(minute) \(m) before your time to leave?"
            }
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        if (textView.text == "Enter a notification message")
        {
            textView.text = ""
            textView.textColor = .black
        }
        textView.becomeFirstResponder() //Optional
    }
    
    func textViewDidEndEditing(_ textView: UITextView)
    {
        if (textView.text == "")
        {
            textView.text = "Enter a notification message"
            textView.textColor = .lightGray
        }
        textView.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func confirmButton(_ sender: Any) {
        print("\(hour):\(minute)")
        let time:Double = Double(3600*hour + 60*minute)
        print("SENDING TO DELEGATE!")
        delegate?.addAlarmList(alarm: Alarm(h:hour, m:minute, t: time, n: nameField.text!, d: descriptionText.text!))
        _ = self.navigationController?.popViewController(animated:true)
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
