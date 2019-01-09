//
//  DepartureView.swift
//  Commuter
//
//  Created by Will Gilman on 12/9/18.
//  Copyright © 2018 BGHFM. All rights reserved.
//

import UIKit

protocol DepartureViewDelegate {
 
    func displayMessage(message: String)
    
    func setNotification(departure: Departure, commute: Commute, action: CommuterAPI.NotificationAction)
}

class DepartureView: UIView {
    
    enum Constant {
        static let expandedCellHeight: CGFloat = 186.0
        static let collapsedCellHeight: CGFloat = 136.0
    }

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var delegate: DepartureViewDelegate!
    var refreshControl: UIRefreshControl!
    var activityAnimation: UIActivityIndicatorView!
    var commute: Commute!
    var trip: Trip! {
        didSet {
            if let label = tableView.viewWithTag(1) {
                label.removeFromSuperview()
            }
            tableView.reloadData()
            if refreshControl.isRefreshing {
                refreshControl.endRefreshing()
            }
            if activityAnimation.isAnimating {
                activityAnimation.stopAnimating()
            }
            for _ in trip.departures {
                cellHeights.append((expanded: false, height: Constant.collapsedCellHeight))
            }
            refreshTimestampLabel()
        }
    }
    var cellHeights = [(expanded: Bool, height: CGFloat)]()
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
        tableView.estimatedRowHeight = Constant.collapsedCellHeight
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        activityAnimation = UIActivityIndicatorView(style: .whiteLarge)
        tableView.backgroundView = activityAnimation
        activityAnimation.color = AppColor.MediumGray.color
        activityAnimation.startAnimating()
        
        timestampLabel = UILabel()
        timestampLabel.font = UIFont.mySystemFont(ofSize: 13)
        timestampLabel.textColor = AppColor.MediumGray.color
        timestampLabel.textAlignment = .center
        tableView.addSubview(timestampLabel)
        timestampLabel.frame = CGRect(x: 0, y: -24, width: tableView.bounds.width, height: 20)
        timestampLabel.isHidden = true
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
            if self.errorStateIsDisplayed() == false {
                if self.dataInitiallyLoaded() == false {
                    // Only show an error in the background if the initial load fails.
                    self.activityAnimation.stopAnimating()
                    let margin: CGFloat = 32
                    let frame = CGRect(x: margin, y: self.tableView.bounds.height / 3, width: self.tableView.bounds.width - margin * 2, height: 44)
                    let label = UILabel(frame: frame)
                    label.text = "Oops, we couldn't to load your commute."
                    label.font = UIFont.systemFont(ofSize: 17)
                    label.textAlignment = .center
                    label.numberOfLines = 0
                    label.tag = 1
                    self.tableView.addSubview(label)
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
        let comp = Calendar.current.dateComponents([.second], from: trip.asOf, to: Date())
        if let sec = comp.second {
            let min: Int = sec / 60
            if sec == 0 {
                timestampLabel.text = "Last updated just now"
            } else if sec < 60 {
                timestampLabel.text = "Last updated \(sec) sec ago"
            } else if min <= 5 {
                timestampLabel.text = "Last updated \(min) min ago"
            } else {
                timestampLabel.text = "Last updated more than 5 min ago"
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
        if cellHeights.count > 0 {
            return cellHeights[indexPath.row].height
        } else {
            return Constant.collapsedCellHeight
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DepartureCell", for: indexPath) as! DepartureCell
        cell.delegate = self
        cell.departure = trip.departures[indexPath.row]
        cell.isExpanded = cellHeights[indexPath.row].expanded
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! DepartureCell
        
        let height = Constant.expandedCellHeight - Constant.collapsedCellHeight
        if cellHeights[indexPath.row].expanded {
            cellHeights[indexPath.row].expanded = false
            cellHeights[indexPath.row].height -= height
            cell.collapse()
        } else {
            cellHeights[indexPath.row].expanded = true
            cellHeights[indexPath.row].height += height
            cell.expand()
        }
        
        UIView.animate(withDuration: AppVariable.duration, delay: 0, options: .curveEaseInOut, animations: {
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }, completion: nil)
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
    
    func setNotification(departure: Departure, action: CommuterAPI.NotificationAction) {
        delegate.setNotification(departure: departure, commute: self.commute, action: action)
    }
}
