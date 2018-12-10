//
//  DepartureView.swift
//  Commuter
//
//  Created by Will Gilman on 12/9/18.
//  Copyright © 2018 BGHFM. All rights reserved.
//

import UIKit

class DepartureView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var trip: Trip! {
        didSet {
            tableView.reloadData()
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
        let nib = UINib(nibName: "DepartureView", bundle: nil)
        nib.instantiate(withOwner: self, options: nil)
        contentView.frame = bounds
        addSubview(contentView)
        setupTableView()
    }
    
    func setupTableView() {
        let departureCell = UINib(nibName: "DepartureCell", bundle: nil)
        tableView.register(departureCell, forCellReuseIdentifier: "DepartureCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 160.0
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
    }
}

extension DepartureView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let trip = trip else { return 0 }
        return trip.departures.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DepartureCell", for: indexPath) as! DepartureCell
        cell.departure = trip.departures[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
}
