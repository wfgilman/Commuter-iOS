//
//  DepartureCell.swift
//  Commuter
//
//  Created by Will Gilman on 12/7/18.
//  Copyright © 2018 BGHFM. All rights reserved.
//

import UIKit

protocol DepartureCellDelegate {
    
    func showActions(departure: Departure, action: CommuterAPI.NotificationAction)
}

class DepartureCell: UITableViewCell {

    // Front View
    @IBOutlet weak var frontView: UIView!
    @IBOutlet weak var frontViewTop: NSLayoutConstraint!
    @IBOutlet weak var routeColorView: UIView!
    @IBOutlet weak var etdMinLabel: UILabel!
    @IBOutlet weak var headsignLabel: UILabel!
    @IBOutlet weak var etaLabel: UILabel!
    @IBOutlet weak var etdLabel: UILabel!
    @IBOutlet weak var dividerView: UIView!
    @IBOutlet weak var isEmptyLabel: UILabel!
    @IBOutlet weak var isEmptyView: UIView!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var notifcationImageView: UIImageView!
    @IBOutlet weak var departLabel: UILabel!
    @IBOutlet weak var arriveLabel: UILabel!

    // Back View
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var backViewTop: NSLayoutConstraint!
    @IBOutlet weak var schedLabel: UILabel!
    @IBOutlet weak var stdLabel: UILabel!
    @IBOutlet weak var delayLabel: UILabel!
    @IBOutlet weak var delayMinLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var durationMinLabel: UILabel!
    @IBOutlet weak var trainLengthLabel: UILabel!
    @IBOutlet weak var lengthLabel: UILabel!
    @IBOutlet weak var priorStopsTitleLabel: UILabel!
    @IBOutlet weak var priorStopsLabel: UILabel!
    @IBOutlet weak var stopsTitleLabel: UILabel!
    @IBOutlet weak var stopsLabel: UILabel!
    
    
    var delegate: DepartureCellDelegate!
    var departure: Departure! {
        didSet {
            setFrontViewData(departure: departure)
            setBackViewData(departure: departure)
        }
    }
    var isFlipped: Bool! {
        didSet {
            if isFlipped {
                backView.isHidden = false
                frontView.isHidden = true
            } else {
                backView.isHidden = true
                frontView.isHidden = false
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureDefaultState()
        
        self.backgroundColor = .clear
        self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.16).cgColor
        self.layer.shadowOffset = .zero
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 4
        
        configureFrontView()
        configureBackView()
    }
    
    func configureDefaultState() {
        self.backViewTop.constant = self.frontViewTop.constant
        backView.isHidden = true
        frontView.isHidden = false
        contentView.bringSubviewToFront(frontView)
    }
    
    func configureFrontView() {
        frontView.layer.cornerRadius = 8
        frontView.layer.borderWidth = 0.5
        frontView.layer.borderColor = AppColor.PaleGray.color.cgColor
        frontView.layer.masksToBounds = true
        
        routeColorView.layer.borderWidth = 0.5
        routeColorView.layer.borderColor = AppColor.PaleGray.color.cgColor
        
        headsignLabel.textAlignment = .left
        headsignLabel.font = UIFont.systemFont(ofSize: 17)
        headsignLabel.textColor = AppColor.Charcoal.color
        
        etdMinLabel.font = UIFont.systemFont(ofSize: 32, weight: .light)
        etdMinLabel.textColor = AppColor.Charcoal.color
        
        departLabel.font = UIFont.systemFont(ofSize: 13)
        departLabel.textColor = AppColor.MediumGray.color
        etdLabel.font = UIFont.systemFont(ofSize: 15)
        etdLabel.textColor = AppColor.Charcoal.color
        
        arriveLabel.font = UIFont.systemFont(ofSize: 13)
        arriveLabel.textColor = AppColor.MediumGray.color
        etaLabel.font = UIFont.systemFont(ofSize: 15)
        etaLabel.textColor = AppColor.Charcoal.color
        
        dividerView.backgroundColor = AppColor.MediumGray.color
        
        isEmptyLabel.font = UIFont.systemFont(ofSize: 10)
        isEmptyLabel.textColor = UIColor.white
        isEmptyView.backgroundColor = AppColor.Blue.color
        isEmptyView.layer.cornerRadius = 4
        isEmptyView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    }
    
    func setFrontViewData(departure: Departure) {
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
        
        isEmptyView.isHidden = !departure.isEmpty
        notifcationImageView.isHidden = !departure.notify
    }
    
    func configureBackView() {
        backView.layer.cornerRadius = 8
        backView.layer.borderWidth = 0.5
        backView.layer.borderColor = AppColor.PaleGray.color.cgColor
        backView.layer.masksToBounds = true
        
        schedLabel.font = UIFont.systemFont(ofSize: 13)
        schedLabel.textColor = AppColor.MediumGray.color
        stdLabel.font = UIFont.systemFont(ofSize: 15)
        stdLabel.textColor = AppColor.Charcoal.color
        
        delayLabel.font = UIFont.systemFont(ofSize: 13)
        delayLabel.textColor = AppColor.MediumGray.color
        delayMinLabel.textColor = AppColor.Charcoal.color
        delayMinLabel.font = UIFont.systemFont(ofSize: 15)
        
        durationLabel.font = UIFont.systemFont(ofSize: 13)
        durationLabel.textColor = AppColor.MediumGray.color
        durationMinLabel.textColor = AppColor.Charcoal.color
        durationMinLabel.font = UIFont.systemFont(ofSize: 15)
        
        trainLengthLabel.font = UIFont.systemFont(ofSize: 13)
        trainLengthLabel.textColor = AppColor.MediumGray.color
        lengthLabel.textColor = AppColor.Charcoal.color
        lengthLabel.font = UIFont.systemFont(ofSize: 15)
        
        priorStopsTitleLabel.font = UIFont.systemFont(ofSize: 13)
        priorStopsTitleLabel.textColor = AppColor.MediumGray.color
        priorStopsLabel.textColor = AppColor.Charcoal.color
        priorStopsLabel.font = UIFont.systemFont(ofSize: 15)
        
        stopsTitleLabel.font = UIFont.systemFont(ofSize: 13)
        stopsTitleLabel.textColor = AppColor.MediumGray.color
        stopsLabel.textColor = AppColor.Charcoal.color
        stopsLabel.font = UIFont.systemFont(ofSize: 15)
    }
    
    func setBackViewData(departure: Departure) {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        timeFormatter.amSymbol = "am"
        timeFormatter.pmSymbol = "pm"
        
        stdLabel.text = timeFormatter.string(from: departure.std)
        if departure.realTime == true {
            if departure.delayMin == 0 {
                delayMinLabel.text = "On Time"
            } else {
                delayMinLabel.text = "\(departure.delayMin) min"
                delayMinLabel.textColor = AppColor.Red.color
            }
        } else {
            delayMinLabel.text = "-"
        }
        durationMinLabel.text = "\(departure.durationMin) min"
        if let length = departure.length {
            lengthLabel.text = "\(length) cars"
        } else {
            lengthLabel.text = "-"
        }
        priorStopsLabel.text = "\(departure.priorStops)"
        stopsLabel.text = "\(departure.stops)"
    }
    
    func flipToBack() {
        UIView.transition(with: self.contentView, duration: 0.5, options: .transitionFlipFromTop, animations: {
            self.frontView.isHidden = true
            self.backView.isHidden = false
        }, completion: nil)
    }
    
    func flipToFront() {
        UIView.transition(with: self.contentView, duration: 0.5, options: .transitionFlipFromTop, animations: {
            self.backView.isHidden = true
            self.frontView.isHidden = false
        }, completion: nil)
    }
    
    @IBAction func onTapActionButton(_ sender: Any) {
        if departure.notify == true {
            delegate.showActions(departure: self.departure, action: .delete)
        } else {
            delegate.showActions(departure: self.departure, action: .store)
        }
    }
    
    override func prepareForReuse() {
        delayMinLabel.textColor = AppColor.Charcoal.color
    }
}
