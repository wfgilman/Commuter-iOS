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
    var selectedStation: String = "MONT"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        stationPickerView.delegate = self
        stationPickerView.dataSource = self
        
        stations = GlobalVariable.stations
        guard let startingRow = stations.firstIndex(where: { (station) -> Bool in
            station.code == self.selectedStation
        }) else { return }
        self.stationPickerView.selectRow(startingRow, inComponent: 0, animated: false)
    }

    @IBAction func onTapSelectButton(_ sender: UIButton) {
        UserDefaults.standard.set(selectedStation, forKey: "DestStationCode")
//        performSegue(withIdentifier: "SelectDestSegue", sender: nil)
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
        UserDefaults.standard.set(stations[row].code, forKey: "DestStationCode")
        return
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return CGFloat(40)
    }
}
