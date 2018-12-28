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
    @IBOutlet weak var highlightView: UIView!
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    @IBOutlet weak var hightlightViewLeft: NSLayoutConstraint!
    
    var morningDepartureView: DepartureView!
    var eveningDepartureView: DepartureView!
    var commute: Commute!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        scrollView.addSubview(morningDepartureView)
        getDepartures(commute: .morning)
        
        eveningDepartureView = DepartureView()
        eveningDepartureView.commute = .evening
        scrollView.addSubview(eveningDepartureView)
        getDepartures(commute: .evening)
        
        highlightView.backgroundColor = AppColor.Charcoal.color
        
        setupSubviews()
        addListener()
        
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
            scrollView.contentOffset.x = 0
        } else {
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
    
    func getDepartures(commute: Commute) {
        var commuteView: DepartureView
        var orig: String
        var dest: String
        
        guard let savedOrig = UserDefaults.standard.string(forKey: "OrigStationCode") else {
            // Show error
            return
        }
        
        guard let savedDest = UserDefaults.standard.string(forKey: "DestStationCode") else {
            // Show error
            return
        }
        
        if commute == .morning {
            orig = savedOrig
            dest = savedDest
            commuteView = self.morningDepartureView
        } else {
            orig = savedDest
            dest = savedOrig
            commuteView = self.eveningDepartureView
        }
        
        CommuterAPI.sharedClient.getTrip(orig: orig, dest: dest, success: { (trip) in
            commuteView.trip = trip
        }) { (_, message) in
            guard let message = message else { return }
            print("\(message)")
        }
    }
    
    func addListener() {
        let name = NSNotification.Name("refreshTrip")
        NotificationCenter.default.addObserver(forName: name, object: nil, queue: .main) { (notification) in
            guard let commute: Commute = notification.object as? Commute else {
                // User changed commute. Wipe and reload the data.
                self.getDepartures(commute: .morning)
                self.morningDepartureView.trip.departures = []
                self.morningDepartureView.tableView.reloadData()
                self.morningDepartureView.activityAnimation.startAnimating()
                
                self.getDepartures(commute: .evening)
                self.eveningDepartureView.trip.departures = []
                self.eveningDepartureView.tableView.reloadData()
                self.eveningDepartureView.activityAnimation.startAnimating()
                return
            }
            // User refreshed. Don't wipe the existing data.
            self.getDepartures(commute: commute)
        }
    }
    
    @IBAction func onTapSettingsButton(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "SettingsSegue", sender: nil)
    }
}

extension DepartureViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        hightlightViewLeft.constant = scrollView.contentOffset.x / 2
    }
}
