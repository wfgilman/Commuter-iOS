//
//  CommuteCell.swift
//  Commuter
//
//  Created by Will Gilman on 12/25/18.
//  Copyright © 2018 BGHFM. All rights reserved.
//

import UIKit

class CommuteCell: UITableViewCell {

    @IBOutlet weak var commuteLabel: UILabel!
    @IBOutlet weak var stationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        commuteLabel.font = UIFont.mySystemFont(ofSize: 15)
        commuteLabel.textColor = AppColor.Charcoal.color
        
        stationLabel.font = UIFont.mySystemFont(ofSize: 15)
        stationLabel.textColor = AppColor.MediumGray.color
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
