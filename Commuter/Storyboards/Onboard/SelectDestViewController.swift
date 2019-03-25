//
//  SelectDestViewController.swift
//  Commuter
//
//  Created by Will Gilman on 12/5/18.
//  Copyright © 2018 BGHFM. All rights reserved.
//

import UIKit

class SelectDestViewController: UIViewController {

    @IBOutlet weak var stationPickerView: UIPickerView!
    @IBOutlet weak var selectButton: UIButton!
    
    var stations = [Station]()
    var selectedStation: Station?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        stationPickerView.delegate = self
        stationPickerView.dataSource = self
        
        stations = AppVariable.stations
        guard let startingRow = stations.firstIndex(where: { (station) -> Bool in
            station.code == "MONT"
        }) else {
            self.selectedStation = self.stations[0]
            return
        }
        self.selectedStation = self.stations[startingRow]
        self.stationPickerView.selectRow(startingRow, inComponent: 0, animated: false)
        
        selectButton.setTitle("Finish", for: .normal)
        selectButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        selectButton.backgroundColor = AppColor.Blue.color
        selectButton.tintColor = UIColor.white
        selectButton.layer.cornerRadius = 4
    }

    @IBAction func onTapSelectButton(_ sender: UIButton) {
        AppVariable.destStation = selectedStation
        performSegue(withIdentifier: "MainSegue", sender: nil)
    }
    
}

extension SelectDestViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
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
        return CGFloat(60)
    }
}
