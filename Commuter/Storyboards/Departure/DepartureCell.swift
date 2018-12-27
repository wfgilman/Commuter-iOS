//
//  DepartureCell.swift
//  Commuter
//
//  Created by Will Gilman on 12/7/18.
//  Copyright © 2018 BGHFM. All rights reserved.
//

import UIKit

class DepartureCell: UITableViewCell {

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
    @IBOutlet weak var isEmptyLabel: UILabel!
    
    @IBOutlet weak var departLabel: UILabel!
    @IBOutlet weak var arriveLabel: UILabel!
    
    @IBOutlet weak var footerViewTop: NSLayoutConstraint!
    
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
            
            isEmptyLabel.isHidden = !departure.isEmpty
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = .clear
        headerView.layer.cornerRadius = 8
        headerView.layer.borderWidth = 0.5
        headerView.layer.borderColor = AppColor.PaleGray.color.cgColor
        headerView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.16).cgColor
        headerView.layer.shadowOffset = .zero
        headerView.layer.shadowOpacity = 1
        headerView.layer.shadowRadius = 4
        headerView.layer.masksToBounds = true
        
        footerView.layer.cornerRadius = 8
        footerView.layer.borderWidth = 0.5
        footerView.layer.borderColor = AppColor.PaleGray.color.cgColor
        footerView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.16).cgColor
        footerView.layer.shadowOffset = .zero
        footerView.layer.shadowOpacity = 1
        footerView.layer.shadowRadius = 4
        
        // Header elements.
        routeColorView.layer.borderWidth = 0.5
        routeColorView.layer.borderColor = AppColor.PaleGray.color.cgColor
        
        headsignLabel.textAlignment = .left
        headsignLabel.font = UIFont.systemFont(ofSize: 17)
        headsignLabel.textColor = AppColor.Charcoal.color
        
        etdMinLabel.font = UIFont.systemFont(ofSize: 24)
        etdMinLabel.textColor = AppColor.Charcoal.color
        
        departLabel.font = UIFont.systemFont(ofSize: 10)
        departLabel.textColor = AppColor.MediumGray.color
        etdLabel.font = UIFont.systemFont(ofSize: 13)
        etdLabel.textColor = AppColor.Charcoal.color
        
        arriveLabel.font = UIFont.systemFont(ofSize: 10)
        arriveLabel.textColor = AppColor.MediumGray.color
        etaLabel.font = UIFont.systemFont(ofSize: 13)
        etaLabel.textColor = AppColor.Charcoal.color
        
        dividerView.backgroundColor = AppColor.MediumGray.color
        
        isEmptyLabel.font = UIFont.systemFont(ofSize: 13)
        isEmptyLabel.textColor = AppColor.Charcoal.color
        
        // Footer elements.
        footerView.backgroundColor = AppColor.PaleGray.color
        
        delayMinLabel.font = UIFont.systemFont(ofSize: 13)
        delayMinLabel.textColor = AppColor.Charcoal.color
        
        stopsLabel.font = UIFont.systemFont(ofSize: 13)
        stopsLabel.textColor = AppColor.Charcoal.color
        
        carsLabel.font = UIFont.systemFont(ofSize: 13)
        carsLabel.textColor = AppColor.Charcoal.color
        
        // Constraints.
        footerViewTop.constant = -60
    }

    func expand() {
        UIView.animate(withDuration: AppVariable.duration, delay: 0, options: .curveEaseOut, animations: {
            self.footerViewTop.constant = -10
            self.layoutIfNeeded()
        }, completion: nil)
        
    }
    
    func collapse() {
        UIView.animate(withDuration: AppVariable.duration, delay: 0, options: .curveEaseOut, animations: {
            self.footerViewTop.constant = -60
            self.layoutIfNeeded()
        }, completion: nil)
        
    }
}
