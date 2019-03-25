//
//  SelectOrigViewController.swift
//  Commuter
//
//  Created by Will Gilman on 12/4/18.
//  Copyright © 2018 BGHFM. All rights reserved.
//

import UIKit
import NotificationBannerSwift
import PickerView

class SelectOrigViewController: UIViewController {

    @IBOutlet weak var pickerView: UIView!
    @IBOutlet weak var stationPickerView: UIPickerView!
    @IBOutlet weak var selectButton: UIButton!
    
    var activityAnimation: UIActivityIndicatorView!
    var stations = [Station]()
    var selectedStation: Station?
    var rowHeight: CGFloat = 80
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pickerView.delegate = self
        pickerView.dataSource = self
        
        activityAnimation = UIActivityIndicatorView(style: .whiteLarge)
        pickerView.addSubview(activityAnimation)
        activityAnimation.color = AppColor.MediumGray.color
        activityAnimation.startAnimating()
        
        selectButton.setTitle("Next", for: .normal)
        selectButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        selectButton.backgroundColor = AppColor.Blue.color
        selectButton.tintColor = UIColor.white
        selectButton.layer.cornerRadius = 4
        
        loadStations()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        activityAnimation.center = pickerContainerView.convert(pickerContainerView.center, from: pickerContainerView.superview)
    }
    
    func loadStations() {
        CommuterAPI.sharedClient.getStations(success: { (stations) in
            AppVariable.stations = stations
            self.stations = stations
            self.stationPickerView.reloadAllComponents()
            self.activityAnimation.stopAnimating()
            self.stationPickerView.isHidden = false
            guard let startingRow = stations.firstIndex(where: { (station) -> Bool in
                station.code == "PHIL"
            }) else {
                self.selectedStation = self.stations[0]
                return
            }
            self.selectedStation = self.stations[startingRow]
            self.stationPickerView.selectRow(startingRow, inComponent: 0, animated: false)
        }) { (_, message) in
            guard let message = message else { return }
            print("\(message)")
            self.activityAnimation.stopAnimating()
            self.showFailedLoadBanner()
        }
    }
    
    @IBAction func onTapSelectButton(_ sender: UIButton) {
        AppVariable.origStation = selectedStation
        performSegue(withIdentifier: "SelectDestSegue", sender: nil)
    }
    
    func showFailedLoadBanner() {
        let banner = NotificationBanner(title: "No Connection", subtitle: "We couldn't load the stations. Tap here to try again.", style: .warning)
        banner.autoDismiss = false
        banner.onTap = {
            self.activityAnimation.startAnimating()
            self.loadStations()
        }
        banner.show()
    }
}

extension SelectOrigViewController: PickerViewDataSource, PickerViewDelegate {
    
    func pickerViewNumberOfRows(_ pickerView: PickerView) -> Int {
        return stations.count
    }
    
    func pickerView(_ pickerView: PickerView, titleForRow row: Int) -> String {
        return stations[row].name
    }
    
    func pickerViewHeightForRows(_ pickerView: PickerView) -> CGFloat {
        return rowHeight
    }
    
    func pickerView(_ pickerView: PickerView, didSelectRow row: Int) {
        selectedStation = stations[row]
    }
    
    func pickerView(_ pickerView: PickerView, viewForRow row: Int, highlighted: Bool, reusingView view: UIView?) -> UIView? {
        <#code#>
    }
}

extension SelectOrigViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
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
