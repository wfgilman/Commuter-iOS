//
//  DepartureView.swift
//  Commuter
//
//  Created by Will Gilman on 12/9/18.
//  Copyright © 2018 BGHFM. All rights reserved.
//

import UIKit

protocol DepartureViewDelegate {
    
    func refreshDepartures(commute: Commute)
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
            tableView.reloadData()
            refreshControl.endRefreshing()
            if activityAnimation.isAnimating {
                activityAnimation.stopAnimating()
            }
            for _ in trip.departures {
                cellHeights.append((expanded: false, height: Constant.collapsedCellHeight))
            }
        }
    }
    var cellHeights = [(expanded: Bool, height: CGFloat)]()
    
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
    }
    
    func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
    }
    
    @objc func onRefresh() {
        delegate.refreshDepartures(commute: commute)
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
            return 120
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DepartureCell", for: indexPath) as! DepartureCell
        cell.departure = trip.departures[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! DepartureCell
        
        if cellHeights[indexPath.row].expanded {
            cellHeights[indexPath.row].expanded = false
            cellHeights[indexPath.row].height -= 50
            cell.collapse()
        } else {
            cellHeights[indexPath.row].expanded = true
            cellHeights[indexPath.row].height += 50
            cell.expand()
        }
        
        UIView.animate(withDuration: AppVariable.duration, delay: 0, options: .curveEaseInOut, animations: {
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }, completion: nil)
    }
}
