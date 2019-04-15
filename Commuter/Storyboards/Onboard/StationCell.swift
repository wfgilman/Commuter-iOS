//
//  StationCell.swift
//  Commuter
//
//  Created by Will Gilman on 3/18/19.
//  Copyright © 2019 BGHFM. All rights reserved.
//

import UIKit

class StationCell: UITableViewCell {
    
    @IBOutlet weak var stationLabel: UILabel!
    @IBOutlet weak var topDot1View: UIView!
    @IBOutlet weak var topDot2View: UIView!
    @IBOutlet weak var topDot3View: UIView!
    @IBOutlet weak var markerView: UIView!
    @IBOutlet weak var bottomDot1View: UIView!
    @IBOutlet weak var bottomDot2View: UIView!
    @IBOutlet weak var bottomDot3View: UIView!
    
    var station: Station! {
        didSet {
            stationLabel.text = station.name
        }
    }
    var inCenter: Bool! {
        didSet {
            if inCenter == true {
                stationLabel.font = UIFont.myBlackSystemFont(ofSize: 20)
                stationLabel.textColor = AppColor.Blue.color
                markerView.backgroundColor = AppColor.Blue.color
            } else {
                stationLabel.font = UIFont.mySystemFont(ofSize: 20)
                stationLabel.textColor = AppColor.Charcoal.color
                markerView.backgroundColor = AppColor.MediumGray.color
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    func setupView() {
        markerView.layer.cornerRadius = 6
        markerView.backgroundColor = AppColor.MediumGray.color
        topDot1View.layer.cornerRadius = 2
        topDot1View.backgroundColor = AppColor.MediumGray.color
        topDot2View.layer.cornerRadius = 2
        topDot2View.backgroundColor = AppColor.MediumGray.color
        topDot3View.layer.cornerRadius = 2
        topDot3View.backgroundColor = AppColor.MediumGray.color
        bottomDot1View.layer.cornerRadius = 2
        bottomDot1View.backgroundColor = AppColor.MediumGray.color
        bottomDot2View.layer.cornerRadius = 2
        bottomDot2View.backgroundColor = AppColor.MediumGray.color
        bottomDot3View.layer.cornerRadius = 2
        bottomDot3View.backgroundColor = AppColor.MediumGray.color
        
        stationLabel.font = UIFont.mySystemFont(ofSize: 20)
    }
    
    
    
    override func prepareForReuse() {
        inCenter = false
    }
    
}
