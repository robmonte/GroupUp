//
//  AlarmTableViewCell.swift
//  GroupUp
//
//  Created by Robert Montefusco on 5/2/17.
//  Copyright © 2017 GroupUp. All rights reserved.
//

import UIKit

class AlarmTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var toggle: UISwitch!
    
    public var cellDelegate: AlarmCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func handledSwitchChange(_ sender: AlarmTableViewCell) {
        self.cellDelegate?.didChangeSwitchState(self, isOn:toggle.isOn)
    }
}
