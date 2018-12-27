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
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    
    var morningDepartureView: DepartureView!
    var eveningDepartureView: DepartureView!
    var commute: Commute!
    var orig: String!
    var dest: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        orig = UserDefaults.standard.string(forKey: "OrigStationCode")
        dest = UserDefaults.standard.string(forKey: "DestStationCode")
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "a"
        switch timeFormatter.string(from: Date()) {
        case "AM":
            commute = .morning
        default:
            commute = .evening
        }
        
        morningDepartureView = DepartureView()
        morningDepartureView.commute = .morning
        morningDepartureView.delegate = self
        scrollView.addSubview(morningDepartureView)
        getDepartures(commute: .morning)
        
        eveningDepartureView = DepartureView()
        eveningDepartureView.commute = .evening
        eveningDepartureView.delegate = self
        scrollView.addSubview(eveningDepartureView)
        getDepartures(commute: .evening)
        
        setupSubviews()
        
        formatNavigationBar()
        navigationItem.title = "My Commute"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        settingsButton.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17)
        ], for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        formatNavigationBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let pageHeight = scrollView.bounds.height
        let pageWidth = scrollView.bounds.width
        
        scrollView.contentSize.width = pageWidth * 2
        scrollView.contentSize.height = pageHeight
        
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
    
    func formatNavigationBar() {
        if let navBar = navigationController?.navigationBar {
            navBar.setup(titleColor: AppColor.Charcoal.color, hasBottomBorder: false, isTranslucent: true)
        }
    }
    
    func setupSubviews() {
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        scrollView.isDirectionalLockEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .automatic
    }
    
    func getStations() {
        
    }
    
    func getDepartures(commute: Commute) {
        var commuteView: DepartureView
        var orig: String
        var dest: String
        
        if commute == .morning {
            orig = self.orig
            dest = self.dest
            commuteView = self.morningDepartureView
        } else {
            orig = self.dest
            dest = self.orig
            commuteView = self.eveningDepartureView
        }
        
        CommuterAPI.sharedClient.getTrip(orig: orig, dest: dest, success: { (trip) in
            commuteView.trip = trip
        }) { (_, message) in
            guard let message = message else { return }
            print("\(message)")
        }
    }
    
    @IBAction func onTapSettingsButton(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "SettingsSegue", sender: nil)
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

extension DepartureViewController: DepartureViewDelegate {
    
    func refreshDepartures(commute: Commute) {
        getDepartures(commute: commute)
    }
}
