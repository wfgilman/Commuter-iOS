//
//  SettingsViewController.swift
//  Commuter
//
//  Created by Will Gilman on 12/20/18.
//  Copyright © 2018 BGHFM. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var commuteStations = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commuteStations.append(UserDefaults.standard.string(forKey: "OrigStationCode") ?? "")
        commuteStations.append(UserDefaults.standard.string(forKey: "DestStationCode") ?? "")

        
        setupTableView()
        
        if let navBar = navigationController?.navigationBar {
            navBar.setup(titleColor: AppColor.Charcoal.color, hasBottomBorder: true, isTranslucent: true)
            navigationItem.title = "Settings"
            navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
    }
    
    func setupTableView() {
        let commuteCell = UINib(nibName: "CommuteCell", bundle: nil)
        tableView.register(commuteCell, forCellReuseIdentifier: "CommuteCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = AppColor.PaleGray.color
        tableView.tableFooterView = UIView()
    }

}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 44)
        let view = UIView(frame: frame)
        view.backgroundColor = AppColor.PaleGray.color
        let labelSize = CGSize(width: 100, height: 16)
        let labelFrame = CGRect(x: 16, y: frame.height - labelSize.height - 8, width: labelSize.width, height: labelSize.height)
        let label = UILabel(frame: labelFrame)
        label.text = "Commute"
        label.font = UIFont.mySystemFont(ofSize: 15)
        label.textColor = AppColor.MediumGray.color
        label.textAlignment = .left
        view.addSubview(label)
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commuteStations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommuteCell", for: indexPath) as! CommuteCell
        if indexPath.row == 0 {
            cell.commuteLabel.text = "From"
        } else {
            cell.commuteLabel.text = "To"
        }
        cell.stationLabel.text = commuteStations[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        <#code#>
//    }
    
    
}
