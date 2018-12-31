//
//  DepartureViewController.swift
//  Commuter
//
//  Created by Will Gilman on 12/6/18.
//  Copyright © 2018 BGHFM. All rights reserved.
//

import UIKit
import NotificationBannerSwift
import UserNotifications

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
    var pageWidth: CGFloat!
    var pageHeight: CGFloat!
    
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
        
        origCommuteLabel.isUserInteractionEnabled = true
        let morningTap = UITapGestureRecognizer(target: self, action: #selector(showMorningView))
        origCommuteLabel.addGestureRecognizer(morningTap)
        
        destCommuteLabel.isUserInteractionEnabled = true
        let eveningTap = UITapGestureRecognizer(target: self, action: #selector(showEveningView))
        destCommuteLabel.addGestureRecognizer(eveningTap)
        
        morningDepartureView = DepartureView()
        morningDepartureView.delegate = self
        morningDepartureView.commute = .morning
        scrollView.addSubview(morningDepartureView)
        getDepartures(commute: .morning)
        
        eveningDepartureView = DepartureView()
        eveningDepartureView.delegate = self
        eveningDepartureView.commute = .evening
        scrollView.addSubview(eveningDepartureView)
        getDepartures(commute: .evening)
        
        highlightView.backgroundColor = AppColor.Charcoal.color
        highlightView.layer.cornerRadius = 1
        highlightView.layer.masksToBounds = true
        
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
        
        pageHeight = scrollView.bounds.height
        pageWidth = scrollView.bounds.width
        
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
        var origCode: String
        var destCode: String
        
        if commute == .morning {
            origCode = AppVariable.origStation!.code
            destCode = AppVariable.destStation!.code
            commuteView = self.morningDepartureView
        } else {
            origCode = AppVariable.destStation!.code
            destCode = AppVariable.origStation!.code
            commuteView = self.eveningDepartureView
        }
        
        CommuterAPI.sharedClient.getTrip(origCode: origCode, destCode: destCode, success: { (trip) in
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
    
    @objc func showMorningView() {
        UIView.animate(withDuration: AppVariable.duration) {
            self.scrollView.contentOffset.x = 0
        }
    }
    
    @objc func showEveningView() {
        UIView.animate(withDuration: AppVariable.duration) {
            self.scrollView.contentOffset.x = self.pageWidth
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

extension DepartureViewController: DepartureViewDelegate {
    
    func displayMessage(message: String) {
        let banner = NotificationBanner(title: "No Connection", subtitle: message, style: .warning)
        // Only show the banner once.
        if NotificationBannerQueue.default.numberOfBanners == 0 {
            banner.show()
        }
    }
    
    func setNotification(departure: Departure, commute: Commute, action: CommuterAPI.NotificationAction) {
        let client = UNUserNotificationCenter.current()
        client.getNotificationSettings { (settings) in
            if settings.authorizationStatus == .notDetermined {
                client.requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { (granted, error) in
                    if granted == true {
                        DispatchQueue.main.async {
                            UIApplication.shared.registerForRemoteNotifications()
                        }
                    }
                })
            } else if settings.authorizationStatus == .authorized {
                guard let token: String = AppVariable.deviceId else {
                    print("no device token")
                    // Device didn't register correctly. Prompt to try again.
                    return
                }
                let station: Station = (commute == .morning) ? AppVariable.origStation! : AppVariable.destStation!
                CommuterAPI.sharedClient.setNotification(deviceId: token, tripId: departure.tripId, stationId: station.id, action: action, success: {
                    // Cascade update to notify property to corresponding view.
                    self.updateDeparture(departure: departure, commute: commute, action: action)
                }, failure: { (_, message) in
                    // Failed to store the notification. Do nothing.
                    guard let message = message else { return }
                    print("\(message)")
                })
                
            } else {
                // User didn't allow notifications. Remind him.
                print("user didn't allow notifications")
                return
            }
        }
    }
    
    private func updateDeparture(departure: Departure, commute: Commute, action: CommuterAPI.NotificationAction) {
        var commuteView: DepartureView
        var trip: Trip
        
        if commute == .morning {
            commuteView = self.morningDepartureView
        } else {
            commuteView = self.eveningDepartureView
        }
        trip = commuteView.trip
        
        // Set the notify property to 'true' for the relevant departure.
        let updatedDepartures = trip.departures.map { (d) -> Departure in
            if d.tripId == departure.tripId {
                let notify = (action == .store) ? true : false
                d.notify = notify
            }
            return d
        }
        trip.departures = updatedDepartures
        commuteView.trip = trip
    }
}
