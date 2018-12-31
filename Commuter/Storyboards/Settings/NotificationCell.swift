//
//  NotificationCell.swift
//  Commuter
//
//  Created by Will Gilman on 12/30/18.
//  Copyright © 2018 BGHFM. All rights reserved.
//

import UIKit

class NotificationCell: UITableViewCell {

    @IBOutlet weak var descripLabel: UILabel!
    
    var notification: Notification! {
        didSet {
            descripLabel.text = notification.descrip
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        descripLabel.font = UIFont.systemFont(ofSize: 17)
        descripLabel.textColor = AppColor.Charcoal.color
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
