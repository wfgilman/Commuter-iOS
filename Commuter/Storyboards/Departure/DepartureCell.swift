//
//  DepartureCell.swift
//  Commuter
//
//  Created by Will Gilman on 12/7/18.
//  Copyright © 2018 BGHFM. All rights reserved.
//

import UIKit

class DepartureCell: UITableViewCell {

    @IBOutlet weak var routeColorView: UIView!
    @IBOutlet weak var etdMinLabel: UILabel!
    @IBOutlet weak var headsignLabel: UILabel!
    @IBOutlet weak var etaLabel: UILabel!
    @IBOutlet weak var dividerView: UIView!
    
    var departure: Departure! {
        didSet {
            etdMinLabel.text = String(describing: departure.etdMin)
            headsignLabel.text = departure.headsign
            
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "h:mm a"
            timeFormatter.amSymbol = "am"
            timeFormatter.pmSymbol = "pm"
            etaLabel.text = timeFormatter.string(from: departure.eta)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        headsignLabel.textAlignment = .right
        dividerView.backgroundColor = UIColor.black
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
