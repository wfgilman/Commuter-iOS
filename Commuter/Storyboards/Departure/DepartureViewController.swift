//
//  DepartureViewController.swift
//  Commuter
//
//  Created by Will Gilman on 12/6/18.
//  Copyright © 2018 BGHFM. All rights reserved.
//

import UIKit

class DepartureViewController: UIViewController {

    @IBOutlet weak var tabBarView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    var tableView = UITableView()
    
    var pageHeight: CGFloat = 0
    var pageWidth: CGFloat = 0
    var trip: Trip!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageHeight = self.view.bounds.height
        pageWidth = self.view.bounds.width
        let orig = UserDefaults.standard.string(forKey: "OrigStationCode")
        let dest = UserDefaults.standard.string(forKey: "DestStationCode")
        
        CommuterAPI.sharedClient.getTrip(orig: orig!, dest: dest!, success: { (trip) in
            self.trip = trip
            self.tableView.reloadData()
        }) { (_, message) in
            guard let message = message else { return }
            print("\(message)")
        }
        
        setupScrollView()
        setupTimeTable()
    }
    
    func setupScrollView() {
        view.layoutIfNeeded()
        
        scrollView.contentSize.width = pageWidth * 2
        scrollView.contentSize.height = pageHeight
        
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        scrollView.isDirectionalLockEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
    }
    
    func setupTimeTable() {
        tableView.frame = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        scrollView.addSubview(tableView)
    }
}

extension DepartureViewController: UIScrollViewDelegate {
    
}

extension DepartureViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trip.departures.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = trip.departures[indexPath.row].headsign
        return cell
    }
}
