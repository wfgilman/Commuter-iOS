//
//  SelectDestViewController.swift
//  Commuter
//
//  Created by Will Gilman on 12/5/18.
//  Copyright © 2018 BGHFM. All rights reserved.
//

import UIKit
import PickerView
import Mixpanel

class SelectDestViewController: UIViewController {

    @IBOutlet weak var pickerView: PickerView!
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
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
        
        gradient = CAGradientLayer()
        gradient.frame = pickerView.bounds
        gradient.colors = [UIColor.clear.cgColor, UIColor.clear.cgColor, UIColor.black.cgColor, UIColor.black.cgColor, UIColor.clear.cgColor, UIColor.clear.cgColor]
        gradient.locations = [0, 0.1, 0.4, 0.6, 0.9, 1]
        pickerView.layer.mask = gradient
        
        stations = AppVariable.stations
        guard let startingRow = stations.firstIndex(where: { (station) -> Bool in
            station.code == "MONT"
        }) else {
            self.selectedStation = self.stations[0]
            return
        }
        self.selectedStation = self.stations[startingRow]
        self.pickerView.selectRow(startingRow, animated: false)
        
        selectButton.setTitle("Finish", for: .normal)
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
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradient.frame = pickerView.bounds
        selectButton.layer.cornerRadius = selectButton.bounds.height / 2
    }

    @IBAction func onTapSelectButton(_ sender: UIButton) {
        guard let orig = AppVariable.origStation else { return }
        guard let dest = selectedStation else { return }
        Mixpanel.mainInstance().track(event: "Selected Destination Station", properties: ["code" : dest.code])
        CommuterAPI.sharedClient.checkCommute(origCode: orig.code, destCode: dest.code
            , success: {
                AppVariable.destStation = self.selectedStation
                self.performSegue(withIdentifier: "MainSegue", sender: nil)
        }) { (_, message) in
            Mixpanel.mainInstance().track(event: "Destination Requires Transfer")
            let alert = UIAlertController(title: "Station Transfer Required", message: message, preferredStyle: .alert)
            let okay = UIAlertAction(title: "Okay", style: .default, handler: nil)
            alert.addAction(okay)
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
}

extension SelectDestViewController: PickerViewDelegate, PickerViewDataSource {

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
