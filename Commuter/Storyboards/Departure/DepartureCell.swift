//
//  DepartureCell.swift
//  Commuter
//
//  Created by Will Gilman on 12/7/18.
//  Copyright © 2018 BGHFM. All rights reserved.
//

import UIKit

class DepartureCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var footerView: UIView!
    
    @IBOutlet weak var routeColorView: UIView!
    @IBOutlet weak var etdMinLabel: UILabel!
    @IBOutlet weak var headsignLabel: UILabel!
    @IBOutlet weak var etaLabel: UILabel!
    @IBOutlet weak var etdLabel: UILabel!
    @IBOutlet weak var dividerView: UIView!
    @IBOutlet weak var delayMinLabel: UILabel!
    @IBOutlet weak var stopsLabel: UILabel!
    @IBOutlet weak var carsLabel: UILabel!
    
    @IBOutlet weak var departLabel: UILabel!
    @IBOutlet weak var arriveLabel: UILabel!
    
    var departure: Departure! {
        didSet {
            // No modification.
            routeColorView.backgroundColor = departure.routeColor
            headsignLabel.text = departure.headsign
            
            // Times.
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "h:mm a"
            timeFormatter.amSymbol = "am"
            timeFormatter.pmSymbol = "pm"
            etaLabel.text = timeFormatter.string(from: departure.eta)
            etdLabel.text = timeFormatter.string(from: departure.etd)
            
            // Formatted strings.
            etdMinLabel.text = String(describing: departure.etdMin)
            delayMinLabel.text = String(describing: departure.delayMin)
            stopsLabel.text = String(describing: departure.priorStops)
            if let length = departure.length {
                carsLabel.text = String(describing: length) + " cars"
            } else {
                carsLabel.text = "--"
            }
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = .clear
        containerView.layer.cornerRadius = 8
        containerView.layer.borderWidth = 0.5
        containerView.layer.borderColor = AppColor.PaleGray.color.cgColor
        containerView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.16).cgColor
        containerView.layer.shadowOffset = .zero
        containerView.layer.shadowOpacity = 1
        containerView.layer.shadowRadius = 4
        
        // Header elements.
        routeColorView.layer.borderWidth = 0.5
        routeColorView.layer.borderColor = AppColor.PaleGray.color.cgColor
        
        headsignLabel.textAlignment = .left
        headsignLabel.font = UIFont.mySystemFont(ofSize: 18)
        headsignLabel.textColor = AppColor.Charcoal.color
        
        etdMinLabel.font = UIFont.mySystemFont(ofSize: 24)
        etdMinLabel.textColor = AppColor.Charcoal.color
        
        departLabel.font = UIFont.mySystemFont(ofSize: 10)
        departLabel.textColor = AppColor.MediumGray.color
        etdLabel.font = UIFont.mySystemFont(ofSize: 12)
        etdLabel.textColor = AppColor.Charcoal.color
        
        arriveLabel.font = UIFont.mySystemFont(ofSize: 10)
        arriveLabel.textColor = AppColor.MediumGray.color
        etaLabel.font = UIFont.mySystemFont(ofSize: 12)
        etaLabel.textColor = AppColor.Charcoal.color
        
        dividerView.backgroundColor = AppColor.MediumGray.color
        
        // Footer elements.
        footerView.backgroundColor = AppColor.PaleGray.color
        
        delayMinLabel.font = UIFont.mySystemFont(ofSize: 12)
        delayMinLabel.textColor = AppColor.Charcoal.color
        
        stopsLabel.font = UIFont.mySystemFont(ofSize: 12)
        stopsLabel.textColor = AppColor.Charcoal.color
        
        carsLabel.font = UIFont.mySystemFont(ofSize: 12)
        carsLabel.textColor = AppColor.Charcoal.color
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
