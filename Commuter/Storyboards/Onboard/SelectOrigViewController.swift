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

    @IBOutlet weak var pickerView: PickerView!
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    var activityAnimation: UIActivityIndicatorView!
    var stations = [Station]()
    var selectedStation: Station?
    var rowHeight: CGFloat = 80
    var gradient: CAGradientLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = AppColor.PaleGray.color
        titleLabel.textColor = AppColor.Blue.color
        
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        pickerView.backgroundColor = AppColor.PaleGray.color
        
        activityAnimation = UIActivityIndicatorView(style: .whiteLarge)
        pickerView.addSubview(activityAnimation)
        activityAnimation.color = AppColor.MediumGray.color
        activityAnimation.startAnimating()
        
        gradient = CAGradientLayer()
        gradient.frame = pickerView.bounds
        gradient.colors = [UIColor.clear.cgColor, UIColor.clear.cgColor, UIColor.black.cgColor, UIColor.black.cgColor, UIColor.clear.cgColor, UIColor.clear.cgColor]
        gradient.locations = [0, 0.1, 0.4, 0.6, 0.9, 1]
        pickerView.layer.mask = gradient
        
        selectButton.setTitle("Next", for: .normal)
        selectButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        selectButton.backgroundColor = AppColor.Blue.color
        selectButton.tintColor = UIColor.white
        selectButton.layer.cornerRadius = 20
        selectButton.layer.shadowColor = AppColor.Blue.color.withAlphaComponent(0.5).cgColor
        selectButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        selectButton.layer.shadowOpacity = 1
        selectButton.layer.shadowRadius = 4
        
        if let navBar = navigationController?.navigationBar {
            navBar.isTranslucent = true
            navBar.setBackgroundImage(UIImage(), for: .default)
            navBar.shadowImage = UIImage()
        }
        
        loadStations()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        activityAnimation.center = pickerView.convert(pickerView.center, from: pickerView.superview)
        gradient.frame = pickerView.bounds
        selectButton.layer.cornerRadius = selectButton.bounds.height / 2
    }
    
    func loadStations() {
        CommuterAPI.sharedClient.getStations(success: { (stations) in
            AppVariable.stations = stations
            self.stations = stations
            self.pickerView.reloadPickerView()
            self.activityAnimation.stopAnimating()
            guard let startingRow = stations.firstIndex(where: { (station) -> Bool in
                station.code == "PHIL"
            }) else {
                self.selectedStation = self.stations[0]
                return
            }
            self.selectedStation = self.stations[startingRow]
            self.pickerView.selectRow(startingRow, animated: false)
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
        var stationView: StationView
        if view == nil  {
            stationView = StationView(frame: CGRect(x: 0, y: 0, width: pickerView.bounds.width, height: rowHeight))
        } else {
            stationView = view as! StationView
        }

        stationView.station = stations[row]
        stationView.highlighted = highlighted
        return stationView
    }
}
