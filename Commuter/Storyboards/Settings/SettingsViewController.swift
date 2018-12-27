//
//  SettingsViewController.swift
//  Commuter
//
//  Created by Will Gilman on 12/20/18.
//  Copyright © 2018 BGHFM. All rights reserved.
//

import UIKit

enum CommuteDirection: String {
    case from
    case to
}

class SettingsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var commuteStations = [String]()
    var pickerView: UIPickerView!
    var stations = [Station]()
    var direction: CommuteDirection!
    var selectedStation: Station!
    var origCode: String!
    var destCode: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        origCode = UserDefaults.standard.string(forKey: "OrigStationCode") ?? ""
        destCode = UserDefaults.standard.string(forKey: "DestStationCode") ?? ""
        
        commuteStations.append(origCode)
        commuteStations.append(destCode)

        if AppVariable.stations.count == 0 {
            CommuterAPI.sharedClient.getStations(success: { (stations) in
                AppVariable.stations = stations
                self.stations = stations
            }) { (_, message) in
                guard let message = message else { return }
                print("\(message)")
            }
        } else {
            stations = AppVariable.stations
        }
        
        setupTableView()
        
        if let navBar = navigationController?.navigationBar {
            navBar.setup(titleColor: AppColor.Charcoal.color, hasBottomBorder: true, isTranslucent: true)
            navigationItem.title = "Settings"
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        if self.isMovingFromParent {
            if (origCode != commuteStations[0]) || (destCode != commuteStations[1]) {
                let name = NSNotification.Name(rawValue: "refreshTrip")
                NotificationCenter.default.post(name: name, object: nil)
            }
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
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textColor = AppColor.Charcoal.color
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
        cell.selectionStyle = .gray
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            showPicker(direction: .from, stationCode: commuteStations[indexPath.row])
        } else {
            showPicker(direction: .to, stationCode: commuteStations[indexPath.row])
        }
    }
    
    func showPicker(direction: CommuteDirection, stationCode: String) {
        let message = "\n\n\n\n\n\n\n\n\n\n\n"
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)

        let margin: CGFloat = 8
        pickerView = UIPickerView()
        pickerView.frame = CGRect(x: margin, y: margin, width: self.view.bounds.width - margin * 4, height: 216)
        alert.view.addSubview(pickerView)
        
        pickerView.delegate = self
        pickerView.dataSource = self
        guard let startingRow = stations.firstIndex(where: { (station) -> Bool in
            station.code == stationCode
        }) else { return }
        pickerView.selectRow(startingRow, inComponent: 0, animated: false)
        
        
        let okay = UIAlertAction(title: "Okay", style: .default) { (_) in
            guard let selectedStation: Station = self.selectedStation else { return }
            if direction == .from {
                UserDefaults.standard.set(selectedStation.code, forKey: "OrigStationCode")
                self.commuteStations[0] = selectedStation.code
            } else {
                UserDefaults.standard.set(selectedStation.code, forKey: "DestStationCode")
                self.commuteStations[1] = selectedStation.code
            }
            self.tableView.reloadData()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(okay)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
}

extension SettingsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return stations.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return stations[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedStation = stations[row]
        return
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return CGFloat(40)
    }
    
}
