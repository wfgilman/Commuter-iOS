//
//  SettingsViewController.swift
//  Commuter
//
//  Created by Will Gilman on 12/20/18.
//  Copyright © 2018 BGHFM. All rights reserved.
//

import UIKit
import Mixpanel

enum CommuteDirection: String {
    case from
    case to
}

class SettingsViewController: UIViewController {

    @IBOutlet weak var navBarView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var commuteStations = [Station]()
    var pickerView: UIPickerView!
    var stations = [Station]()
    var direction: CommuteDirection!
    var selectedStation: Station!
    var orig: Station!
    var dest: Station!
    var notifications = [Notification]() {
        didSet {
            tableView.reloadSections([1, 2], with: .none)
        }
    }
    var didDeleteNotification: Bool! = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBarView.backgroundColor = AppColor.Blue.color
        
        orig = AppVariable.origStation!
        dest = AppVariable.destStation!
        
        commuteStations.append(orig)
        commuteStations.append(dest)

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
        
        notifications.removeAll()
        getNotifications()
        
        setupTableView()
        
        if let navBar = navigationController?.navigationBar {
            navBar.setup(titleColor: UIColor.white, hasBottomBorder: false, isTranslucent: true)
            navigationItem.title = "Settings"
        }
        Mixpanel.mainInstance().track(event: "Viewed Settings")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        let didChangeOrig: Bool = (orig.code != commuteStations[0].code)
        let didChangeDest: Bool = (dest.code != commuteStations[1].code)
        
        if self.isMovingFromParent {
            if didChangeOrig || didChangeDest || didDeleteNotification {
                let name = NSNotification.Name(rawValue: "refreshTrip")
                NotificationCenter.default.post(name: name, object: nil)
            }
        }
    }
    
    func setupTableView() {
        let commuteCell = UINib(nibName: "CommuteCell", bundle: nil)
        let muteCell = UINib(nibName: "MuteNotificationsCell", bundle: nil)
        let notifCell = UINib(nibName: "NotificationCell", bundle: nil)
        tableView.register(commuteCell, forCellReuseIdentifier: "CommuteCell")
        tableView.register(muteCell, forCellReuseIdentifier: "MuteCell")
        tableView.register(notifCell, forCellReuseIdentifier: "NotifCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.bounces = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = AppColor.PaleGray.color
        let borderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 0.5))
        borderView.backgroundColor = tableView.separatorColor
        tableView.tableFooterView = borderView
    }
    
    func getNotifications() {
        CommuterAPI.sharedClient.getNotifications(success: { (notifications) in
            self.notifications = notifications
        }) { (_, message) in
            guard let message = message else { return }
            print("\(message)")
        }
    }

}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
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
        label.textColor = AppColor.MediumGray.color
        label.textAlignment = .left
        let topBorderFrame = CGRect(x: 0, y: 0, width: frame.width, height: 0.5)
        let bottomBorderFrame = CGRect(x: 0, y: frame.height - 0.5, width: frame.width, height: 0.5)
        let topBorderView = UIView(frame: topBorderFrame)
        let bottomBorderView = UIView(frame: bottomBorderFrame)
        topBorderView.backgroundColor = tableView.separatorColor
        bottomBorderView.backgroundColor = tableView.separatorColor
        view.addSubview(label)
        view.addSubview(topBorderView)
        view.addSubview(bottomBorderView)
        if section == 0 {
            label.text = "Commute"
        } else {
            label.text = "Notifications"
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) || (section == 1) {
            return 44
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return commuteStations.count
            
        } else if section == 1 {
            return 1
            
        } else {
            return notifications.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommuteCell", for: indexPath) as! CommuteCell
            if indexPath.row == 0 {
                cell.commuteLabel.text = "From"
            } else {
                cell.commuteLabel.text = "To"
            }
            cell.stationLabel.text = commuteStations[indexPath.row].code
            cell.selectionStyle = .gray
            return cell
            
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MuteCell", for: indexPath) as! MuteNotificationsCell
            cell.delegate = self
            cell.muteSwitch.isOn = AppVariable.muted
            cell.selectionStyle = .none
            if notifications.count == 0 {
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: tableView.frame.width)
            }
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NotifCell", for: indexPath) as! NotificationCell
            cell.notification = notifications[indexPath.row]
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if indexPath.section == 2 {
            return UITableViewCell.EditingStyle.delete
        }
        return UITableViewCell.EditingStyle.none
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            Mixpanel.mainInstance().track(event: "Deleted Notification")
            CommuterAPI.sharedClient.deleteNotification(notification: notifications[indexPath.row], success: {
                self.didDeleteNotification = true
                self.notifications.remove(at: indexPath.row)
            }) { (_, message) in
                guard let message = message else { return }
                print("\(message)")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            tableView.deselectRow(at: indexPath, animated: true)
            if indexPath.row == 0 {
                showPicker(direction: .from, station: commuteStations[indexPath.row])
            } else {
                showPicker(direction: .to, station: commuteStations[indexPath.row])
            }
        }
    }
    
    private func showPicker(direction: CommuteDirection, station: Station) {
        let message = "\n\n\n\n\n\n\n\n\n\n\n"
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)

        let margin: CGFloat = 8
        pickerView = UIPickerView()
        pickerView.frame = CGRect(x: margin, y: margin, width: self.view.bounds.width - margin * 4, height: 216)
        alert.view.addSubview(pickerView)
        
        pickerView.delegate = self
        pickerView.dataSource = self
        guard let startingRow = stations.firstIndex(where: { (s) -> Bool in
            s.code == station.code
        }) else { return }
        pickerView.selectRow(startingRow, inComponent: 0, animated: false)
        selectedStation = stations[startingRow]
        
        let okay = UIAlertAction(title: "Okay", style: .default) { (_) in
            guard let selectedStation: Station = self.selectedStation else { return }
            var otherStation: Station
            if direction == .from {
                otherStation = self.dest
            } else {
                otherStation = self.orig
            }
            CommuterAPI.sharedClient.checkCommute(origCode: selectedStation.code, destCode: otherStation.code, success: {
                self.saveSelectedStation(direction: direction, station: selectedStation)
                self.tableView.reloadData()
            }, failure: { (_, message) in
                Mixpanel.mainInstance().track(event: "Destination Requires Transfer")
                let alert = UIAlertController(title: "Station Transfer Required", message: message, preferredStyle: .alert)
                let okay = UIAlertAction(title: "Okay", style: .default, handler: nil)
                alert.addAction(okay)
                self.present(alert, animated: true, completion: nil)
            })
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(okay)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    private func saveSelectedStation(direction: CommuteDirection, station: Station) {
        if direction == .from {
            Mixpanel.mainInstance().track(event: "Changed Origin Station", properties: ["oldStation" : self.orig.code, "newStation" : selectedStation.code])
            AppVariable.origStation = selectedStation
            commuteStations[0] = selectedStation
        } else {
            Mixpanel.mainInstance().track(event: "Changed Destination Station", properties: ["oldStation" : self.dest.code, "newStation" : selectedStation.code])
            AppVariable.destStation = selectedStation
            commuteStations[1] = selectedStation
        }
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

extension SettingsViewController: MuteNotificationsCellDelegate {
    
    func changedNotificationSetting(action: CommuterAPI.NotificationSettingAction) {
        if action == .mute {
            Mixpanel.mainInstance().track(event: "Muted Notifications")
        } else {
            Mixpanel.mainInstance().track(event: "Unmuted Notifications")
        }
        CommuterAPI.sharedClient.setDeviceNotificationSetting(action: action, success: {
            let muted: Bool = (action == .mute) ? true : false
            AppVariable.muted = muted
            self.tableView.reloadSections([1], with: .none)
        }) { (_, _) in
            // Show a notificaton to user that the setting wasn't saved.
            self.tableView.reloadSections([1], with: .none)
        }
    }
}
