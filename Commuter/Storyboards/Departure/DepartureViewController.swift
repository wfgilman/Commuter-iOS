//
//  DepartureViewController.swift
//  Commuter
//
//  Created by Will Gilman on 12/6/18.
//  Copyright © 2018 BGHFM. All rights reserved.
//

import UIKit

enum Commute: String {
    case morning
    case evening
}

class DepartureViewController: UIViewController {

    @IBOutlet weak var tabBarView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var origCommuteLabel: UILabel!
    @IBOutlet weak var destCommuteLabel: UILabel!
    @IBOutlet weak var origColorView: UIView!
    @IBOutlet weak var destColorView: UIView!
    
    var morningDepartureView: DepartureView!
    var eveningDepartureView: DepartureView!
    var commute: Commute!
    var pageHeight: CGFloat = 0
    var pageWidth: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageHeight = self.view.bounds.height
        pageWidth = self.view.bounds.width
        let orig = UserDefaults.standard.string(forKey: "OrigStationCode")
        let dest = UserDefaults.standard.string(forKey: "DestStationCode")
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "a"
        switch timeFormatter.string(from: Date()) {
        case "AM":
            commute = .morning
        default:
            commute = .evening
        }
        
        morningDepartureView = DepartureView()
        eveningDepartureView = DepartureView()
        scrollView.addSubview(morningDepartureView)
        scrollView.addSubview(eveningDepartureView)
        
        // Get Morning commute trip.
        CommuterAPI.sharedClient.getTrip(orig: orig!, dest: dest!, success: { (trip) in
            self.morningDepartureView.trip = trip
        }) { (_, message) in
            guard let message = message else { return }
            print("\(message)")
        }
        
        // Get Evening commute trip.
        CommuterAPI.sharedClient.getTrip(orig: dest!, dest: orig!, success: { (trip) in
            self.eveningDepartureView.trip = trip
        }) { (_, message) in
            guard let message = message else { return }
            print("\(message)")
        }
        
        setupSubviews()
    }
    
    func setupSubviews() {
        view.layoutIfNeeded()
        
        scrollView.contentSize.width = pageWidth * 2
        scrollView.contentSize.height = pageHeight
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        scrollView.isDirectionalLockEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        
        morningDepartureView.frame = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        eveningDepartureView.frame = CGRect(x: pageWidth, y: 0, width: pageWidth, height: pageHeight)
        
        if commute == .morning {
            origColorView.backgroundColor = .black
            destColorView.backgroundColor = .clear
            scrollView.contentOffset.x = 0
        } else {
            destColorView.backgroundColor = .black
            origColorView.backgroundColor = .clear
            scrollView.contentOffset.x = pageWidth
            
        }
    }
}

extension DepartureViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x == 0 {
            origColorView.backgroundColor = .black
            destColorView.backgroundColor = .clear
        } else {
            destColorView.backgroundColor = .black
            origColorView.backgroundColor = .clear
        }
    }
}
