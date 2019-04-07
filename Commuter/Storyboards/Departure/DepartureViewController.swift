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
import MapKit

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
    @IBOutlet weak var fabView: UIView!
    
    var morningDepartureView: DepartureView!
    var eveningDepartureView: DepartureView!
    var commute: Commute!
    var pageWidth: CGFloat!
    var pageHeight: CGFloat!
    var fab: UIImageView!
    var calculatingAlertController: UIAlertController!
    var highlightOrigMinX: CGFloat!
    var highlightDestMinX: CGFloat!
    
    private var notifDeparture: Departure?
    private var notifCommute: Commute?
    private var notifAction: CommuterAPI.NotificationAction?
    
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
        
        highlightView.backgroundColor = UIColor.white
        highlightView.layer.cornerRadius = 2
        highlightView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        highlightView.layer.masksToBounds = true
        
        setupSubviews()
        addListener()
        addInitialNotificationListener()
        
        formatNavigationBar()
        navigationItem.title = "My Commute"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        settingsButton.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17)
        ], for: .normal)
        
        getAdvisory()
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
        
        let origCenterX = origCommuteLabel.frame.midX
        let destCenterX = destCommuteLabel.frame.midX
        let widthCenter = highlightView.frame.width / 2
        highlightOrigMinX = origCenterX - widthCenter
        highlightDestMinX = destCenterX - widthCenter
        hightlightViewLeft.constant = highlightOrigMinX
    }
    
    private func formatNavigationBar() {
        if let navBar = navigationController?.navigationBar {
            navBar.setup(titleColor: UIColor.white, hasBottomBorder: false, isTranslucent: true)
        }
    }
    
    private func setupSubviews() {
        self.view.backgroundColor = AppColor.Blue.color
        tabBarView.backgroundColor = AppColor.Blue.color
        
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        scrollView.isDirectionalLockEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .automatic
        
        fabView.backgroundColor = AppColor.Blue.color
        fabView.layer.cornerRadius = fabView.frame.width / 2
        fabView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.16).cgColor
        fabView.layer.shadowOffset = .zero
        fabView.layer.shadowOpacity = 1
        fabView.layer.shadowRadius = 4
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(getETA))
        fabView.addGestureRecognizer(tapGesture)
    }
    
    private func getDepartures(commute: Commute) {
        var commuteView: DepartureView = self.morningDepartureView
        var origCode: String = AppVariable.origStation!.code
        var destCode: String = AppVariable.destStation!.code
        
        if commute == .evening {
            origCode = AppVariable.destStation!.code
            destCode = AppVariable.origStation!.code
            commuteView = self.eveningDepartureView
        }
        
        CommuterAPI.sharedClient.getTrip(origCode: origCode, destCode: destCode, success: { (trip) in
            commuteView.trip = trip
            self.checkRealTime(trip: trip)
        }) { (_, message) in
            guard let message = message else { return }
            print("\(message)")
        }
    }
    
    private func checkRealTime(trip: Trip) {
        if trip.includesRealTime == false {
            let banner = NotificationBanner(title: "No Real-Time", subtitle: "Real-time data didn't load. Pull to refresh.", style: .warning)
            banner.duration = AppVariable.bannerDuration
            if NotificationBannerQueue.default.numberOfBanners == 0 {
                banner.show()
            }
        }
    }
    
    private func addListener() {
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
    
    private func addInitialNotificationListener() {
        NotificationCenter.default.addObserver(forName: AppVariable.grantedNotificationAuth, object: nil, queue: .main, using: { (_) in
            guard let departure = self.notifDeparture else { return }
            guard let commute = self.notifCommute else { return }
            guard let action = self.notifAction else { return }
            self.setNotification(departure: departure, commute: commute, action: action)
        })
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
    
    private func setNotification(departure: Departure, commute: Commute, action: CommuterAPI.NotificationAction) {
        let client = UNUserNotificationCenter.current()
        client.getNotificationSettings { (settings) in
            if settings.authorizationStatus == .notDetermined {
                client.requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { (granted, error) in
                    if granted == true {
                        DispatchQueue.main.async {
                            // Store the notification parameters so the notification can be set after the device token is issued to complete the function.
                            self.notifDeparture = departure
                            self.notifCommute = commute
                            self.notifAction = action
                            UIApplication.shared.registerForRemoteNotifications()
                        }
                    }
                })
            } else if settings.authorizationStatus == .authorized {
                guard let token: String = AppVariable.deviceId else {
                    print("no device token")
                    // Device didn't register correctly. Prompt to try again.
                    DispatchQueue.main.async {
                        self.notifDeparture = departure
                        self.notifCommute = commute
                        self.notifAction = action
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                    return
                }
                let station: Station = (commute == .morning) ? AppVariable.origStation! : AppVariable.destStation!
                CommuterAPI.sharedClient.setNotification(deviceId: token, tripId: departure.tripId, stationCode: station.code, action: action, success: {
                    // Cascade update to notify property to corresponding view.
                    self.updateDeparture(departure: departure, commute: commute, action: action)
                }, failure: { (_, _) in
                    let banner = NotificationBanner.init(title: "Something went wrong", subtitle: "We couldn't set your notification. Our bad.", style: .warning)
                    banner.duration = AppVariable.bannerDuration
                    banner.show()
                })
                
            } else {
                // User didn't allow notifications. Remind him.
                DispatchQueue.main.async {
                    let banner = NotificationBanner.init(title: "Notifications Disabled", subtitle: "Enable them for Commuter in your Settings.", style: .info)
                    banner.duration = AppVariable.bannerDuration
                    banner.show()
                }
            }
        }
    }
    
    private func updateDeparture(departure: Departure, commute: Commute, action: CommuterAPI.NotificationAction) {
        var commuteView: DepartureView

        if commute == .morning {
            commuteView = self.morningDepartureView
        } else {
            commuteView = self.eveningDepartureView
        }
        
        var i = 0
        for d in commuteView.trip.departures {
            if d.tripId == departure.tripId {
                let notify = (action == .store) ? true : false
                d.notify = notify
                commuteView.trip.departures[i] = departure
                let indexPath = IndexPath(row: i, section: 0)
                commuteView.tableView.reloadRows(at: [indexPath], with: .none)
            }
            i += 1
        }
    }
    
    @objc func getETA() {
        let locationManager = CLLocationManager()
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            getETA()
            
        } else if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            showCalculatingIndicator()
            guard let location = locationManager.location else {
                self.calculatingAlertController.dismiss(animated: true, completion: nil)
                return
            }
            var orig: Station = AppVariable.origStation!
            var dest: Station = AppVariable.destStation!

            if commute == .evening {
                orig = AppVariable.destStation!
                dest = AppVariable.origStation!
            }
            CommuterAPI.sharedClient.getEta(location: location, origCode: orig.code, destCode: dest.code, success: { (eta) in
                self.calculatingAlertController.dismiss(animated: false, completion: {
                    self.showETA(eta: eta, destination: dest)
                })
            }) { (_, _) in
                self.calculatingAlertController.dismiss(animated: false, completion: {
                    let alert = UIAlertController(title: "No ETA", message: "We couldn't estimated an arrival time based on your current location.", preferredStyle: .alert)
                    let dismiss = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
                    alert.addAction(dismiss)
                    self.present(alert, animated: true, completion: nil)
                })
            }
        }
    }
    
    private func showCalculatingIndicator() {
        calculatingAlertController = UIAlertController(title: "Calculating", message: nil, preferredStyle: .alert)
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.tag = 1
        activityIndicator.frame = activityIndicator.frame.offsetBy(dx: 40, dy: (calculatingAlertController.view.bounds.height - activityIndicator.frame.height) / 2)
        activityIndicator.autoresizingMask = [.flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        activityIndicator.startAnimating()
        calculatingAlertController.view.addSubview(activityIndicator)
        present(calculatingAlertController, animated: true, completion: nil)
    }
    
    private func showETA(eta: ETA, destination: Station) {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        timeFormatter.amSymbol = "am"
        timeFormatter.pmSymbol = "pm"
        let time = timeFormatter.string(from: eta.eta)
        let title = "Arrival: \(time)"
        var message = "Based on your current location you are \(eta.nextStationEtaMin) min from \(eta.nextStation.name) and \(eta.etaMin) min from your destination."
        if (eta.nextStation.code == destination.code) && (eta.nextStationEtaMin == 0) {
            message = "Based on your current location you are presently arriving at your destination."
        }
        if eta.nextStation.code == destination.code {
            message = "Based on your current location you are \(eta.etaMin) min from your destination."
        }
        if eta.nextStationEtaMin == 0 {
            message = "Based on your current location you are approaching \(eta.nextStation.name) and \(eta.etaMin) min from your destination."
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let dismiss = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
        
        let share = UIAlertAction(title: "Share", style: .default) { (_) in
            let eta = "Arriving \(destination.code) at \(time)"
            let activity = UIActivityViewController(activityItems: [eta], applicationActivities: nil)
            
            self.present(activity, animated: true, completion: nil)
        }
        
        alert.addAction(dismiss)
        alert.addAction(share)
        present(alert, animated: true, completion: nil)
    }
    
    func getAdvisory() {
        CommuterAPI.sharedClient.getAdvisory(success: { (advisory) in
            guard let advisory = advisory else { return }
            let banner = StatusBarNotificationBanner(title: advisory, style: .danger)
            banner.autoDismiss = false
            banner.show()
        }) { (_, _) in
            return
        }
    }
}

extension DepartureViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let percentage = scrollView.contentOffset.x / pageWidth
        let leftConstant = (highlightDestMinX - highlightOrigMinX) * percentage
        hightlightViewLeft.constant = leftConstant + highlightOrigMinX
    }
}

extension DepartureViewController: DepartureViewDelegate {
    
    func showActions(departure: Departure, commute: Commute, action: CommuterAPI.NotificationAction) {
        let actions = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let setNotif = UIAlertAction(title: "Set Notification", style: .default) { (_) in
            self.setNotification(departure: departure, commute: commute, action: .store)
        }
        
        let deleteNotif = UIAlertAction(title: "Delete Notification", style: .destructive) { (_) in
            self.setNotification(departure: departure, commute: commute, action: .delete)
        }
        
        let share = UIAlertAction(title: "Share ETA", style: .default) { (_) in
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "h:mm a"
            timeFormatter.amSymbol = "am"
            timeFormatter.pmSymbol = "pm"
            let time = timeFormatter.string(from: departure.eta)
            
            var station = AppVariable.destStation!.code
            if commute == .evening {
                station = AppVariable.origStation!.code
            }
            
            let eta = "Arriving \(station) at \(time)"
            let activity = UIActivityViewController(activityItems: [eta], applicationActivities: nil)
            
            self.present(activity, animated: true, completion: nil)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actions.addAction(share)
        if action == .store {
            actions.addAction(setNotif)
        } else {
            actions.addAction(deleteNotif)
        }
        actions.addAction(cancel)
        present(actions, animated: true, completion: nil)
    }
    
    func displayMessage(message: String) {
        let banner = NotificationBanner(title: "No Connection", subtitle: message, style: .warning)
        banner.duration = AppVariable.bannerDuration
        // Only show the banner once.
        if NotificationBannerQueue.default.numberOfBanners == 0 {
            banner.show()
        }
    }
}
