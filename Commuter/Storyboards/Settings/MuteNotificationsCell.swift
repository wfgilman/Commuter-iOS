//
//  MuteNotificationsCell.swift
//  Commuter
//
//  Created by Will Gilman on 12/30/18.
//  Copyright © 2018 BGHFM. All rights reserved.
//

import UIKit

protocol MuteNotificationsCellDelegate {
    func changedNotificationSetting(action: CommuterAPI.NotificationSettingAction)
}

class MuteNotificationsCell: UITableViewCell {

    @IBOutlet weak var muteLabel: UILabel!
    @IBOutlet weak var muteSwitch: UISwitch!
    
    var delegate: MuteNotificationsCellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        muteLabel.font = UIFont.systemFont(ofSize: 17)
        muteLabel.textColor = AppColor.Charcoal.color
    }
    
    @IBAction func onSwitch(_ sender: UISwitch) {
        if muteSwitch.isOn {
            delegate.changedNotificationSetting(action: .mute)
        } else {
            delegate.changedNotificationSetting(action: .unmute)
        }
    }
}
