//
//  MuteNotificationsCell.swift
//  Commuter
//
//  Created by Will Gilman on 12/30/18.
//  Copyright © 2018 BGHFM. All rights reserved.
//

import UIKit

class MuteNotificationsCell: UITableViewCell {

    @IBOutlet weak var muteLabel: UILabel!
    @IBOutlet weak var muteSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        muteLabel.font = UIFont.systemFont(ofSize: 17)
        muteLabel.textColor = AppColor.Charcoal.color
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
