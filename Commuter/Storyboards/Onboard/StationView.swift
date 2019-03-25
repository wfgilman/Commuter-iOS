//
//  StationView.swift
//  Commuter
//
//  Created by Will Gilman on 2/28/19.
//  Copyright © 2019 BGHFM. All rights reserved.
//

import UIKit

class StationView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var markerView: UIView!
    @IBOutlet weak var topDot1View: UIView!
    @IBOutlet weak var topDot2View: UIView!
    @IBOutlet weak var topDot3View: UIView!
    @IBOutlet weak var bottomDot1View: UIView!
    @IBOutlet weak var bottomDot2View: UIView!
    @IBOutlet weak var bottomDot3View: UIView!
    @IBOutlet weak var stationLabel: UILabel!
    
    var station: Station! {
        didSet {
            stationLabel.text = station.name
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        initSubviews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }
    
    func initSubviews() {
        let nib = UINib(nibName: "StationView", bundle: nil)
        nib.instantiate(withOwner: self, options: nil)
        contentView.frame = bounds
        addSubview(contentView)
        setupView()
    }
    
    func setupView() {
        markerView.layer.cornerRadius = 5
        topDot1View.layer.cornerRadius = 1.5
        topDot2View.layer.cornerRadius = 1.5
        topDot3View.layer.cornerRadius = 1.5
        bottomDot1View.layer.cornerRadius = 1.5
        bottomDot2View.layer.cornerRadius = 1.5
        bottomDot3View.layer.cornerRadius = 1.5
    }
}
