//
//  DepartureView.swift
//  Commuter
//
//  Created by Will Gilman on 12/9/18.
//  Copyright © 2018 BGHFM. All rights reserved.
//

import UIKit
import Mixpanel

enum NoTrainsReason: String {
    case failedLoad
    case noneScheduled
}

protocol DepartureViewDelegate {
 
    func displayMessage(message: String)
        
    func showActions(departure: Departure, commute: Commute, action: CommuterAPI.NotificationAction)
}

class DepartureView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var delegate: DepartureViewDelegate!
    var refreshControl: UIRefreshControl!
    var activityAnimation: UIActivityIndicatorView!
    var commute: Commute!
    var trip: Trip! {
        didSet {
            if let failedLabel = tableView.viewWithTag(1) {
                failedLabel.removeFromSuperview()
            }
            if let noTrainsLabel = tableView.viewWithTag(2) {
                noTrainsLabel.removeFromSuperview()
            }
            if refreshControl.isRefreshing {
                refreshControl.endRefreshing()
            }
            if activityAnimation.isAnimating {
                activityAnimation.stopAnimating()
            }
            cellFlippedStates.removeAll()
            for _ in trip.departures {
                cellFlippedStates.append((isFlipped: false, isLoaded: false))
            }
            refreshTimestampLabel()
            tableView.reloadData()
            if trip.departures.count == 0 && !errorStateIsDisplayed() {
                showEmptyState(reason: .noneScheduled)
            }
        }
    }
    var cellFlippedStates = [(isFlipped: Bool, isLoaded: Bool)]()
    var rowHeight: CGFloat = 136
    var failedLoadLabel: UILabel!
    var timestampLabel: UILabel!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        initSubviews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        tableView.layoutIfNeeded()
        timestampLabel = UILabel()
        timestampLabel.font = UIFont.mySystemFont(ofSize: 13)
        timestampLabel.textColor = AppColor.MediumGray.color
        timestampLabel.textAlignment = .center
        tableView.addSubview(timestampLabel)
        timestampLabel.frame = CGRect(x: 0, y: -24, width: tableView.bounds.width, height: 20)
        timestampLabel.isHidden = true
    }
    
    func initSubviews() {
        let nib = UINib(nibName: "DepartureView", bundle: nil)
        nib.instantiate(withOwner: self, options: nil)
        contentView.frame = bounds
        addSubview(contentView)
        setupTableView()
        setupRefreshControl()
        addListener()
    }
    
    func setupTableView() {
        let departureCell = UINib(nibName: "DepartureCell", bundle: nil)
        tableView.register(departureCell, forCellReuseIdentifier: "DepartureCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = rowHeight
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        activityAnimation = UIActivityIndicatorView(style: .whiteLarge)
        tableView.backgroundView = activityAnimation
        activityAnimation.color = AppColor.MediumGray.color
        activityAnimation.startAnimating()
    }
    
    func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = AppColor.MediumGray.color
        refreshControl.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
    }
    
    @objc func onRefresh() {
        let name = NSNotification.Name(rawValue: "refreshTrip")
        NotificationCenter.default.post(name: name, object: commute)
    }
    
    func addListener() {
        let name = NSNotification.Name("failedLoad")
        NotificationCenter.default.addObserver(forName: name, object: nil, queue: .main) { (_) in
            Mixpanel.mainInstance().track(event: "Failed to Load Departures")
            if self.errorStateIsDisplayed() == false {
                if self.dataInitiallyLoaded() == false {
                    // Only show an error in the background if the initial load fails.
                    self.activityAnimation.stopAnimating()
                    self.showEmptyState(reason: .failedLoad)
                    return
                }
            }
            // Display a banner that the refresh failed.
            if self.refreshControl.isRefreshing {
                self.delegate.displayMessage(message: "We couldn't to load your commute.")
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    func showEmptyState(reason: NoTrainsReason) {
        let margin: CGFloat = 32
        let frame = CGRect(x: margin, y: self.tableView.bounds.height / 3, width: self.tableView.bounds.width - margin * 2, height: 44)
        let label = UILabel(frame: frame)
        label.font = UIFont.systemFont(ofSize: 17)
        label.textAlignment = .center
        label.numberOfLines = 0
        if reason == .failedLoad {
            label.text = "Oops, we couldn't to load your commute."
            label.tag = 1
        } else {
            label.text = "No more trains today 😕"
            label.tag = 2
        }
        tableView.addSubview(label)
    }
    
    private func errorStateIsDisplayed() -> Bool {
        if self.tableView.viewWithTag(1) == nil {
            return false
        } else {
            return true
        }
    }
    
    private func dataInitiallyLoaded() -> Bool {
        if self.trip == nil {
            return false
        } else {
            return true
        }
    }
    
    func refreshTimestampLabel() {
        guard let trip = trip else { return }
        let comp = Calendar.current.dateComponents([.second], from: trip.asOf, to: Date())
        if let sec = comp.second {
            let min: Int = sec / 60
            if sec == 0 {
                timestampLabel.text = "Updated just now"
            } else if sec < 60 {
                timestampLabel.text = "Updated \(sec) sec ago"
            } else if min <= 5 {
                timestampLabel.text = "Updated \(min) min ago"
            } else {
                timestampLabel.text = "Updated more than 5 min ago"
            }
        }
    }
}

extension DepartureView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let trip = trip else { return 0 }
        return trip.departures.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DepartureCell", for: indexPath) as! DepartureCell
        cell.delegate = self
        cell.departure = trip.departures[indexPath.row]
        cell.isFlipped = cellFlippedStates[indexPath.row].isFlipped
        if cellFlippedStates[indexPath.row].isLoaded == false {
            cell.flipToFront()
            cellFlippedStates[indexPath.row].isLoaded = true
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! DepartureCell
        if cellFlippedStates[indexPath.row].isFlipped == false {
            cellFlippedStates[indexPath.row].isFlipped = true
            cell.flipToBack()
            Mixpanel.mainInstance().track(event: "Flipped Departure to Back")
        } else {
            cellFlippedStates[indexPath.row].isFlipped = false
            cell.flipToFront()
            Mixpanel.mainInstance().track(event: "Flipped Departure to Front")
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let isScrollingUp = scrollView.contentOffset.y == 0
        if isScrollingUp {
            refreshTimestampLabel()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let isScrollingUp = scrollView.contentOffset.y < 0
        if isScrollingUp {
            timestampLabel.frame.offsetBy(dx: 0, dy: scrollView.contentOffset.y)
            timestampLabel.isHidden = false
        }
    }
}

extension DepartureView: DepartureCellDelegate {
    
    func showActions(departure: Departure, action: CommuterAPI.NotificationAction) {
        delegate.showActions(departure: departure, commute: self.commute, action: action)
    }
}
