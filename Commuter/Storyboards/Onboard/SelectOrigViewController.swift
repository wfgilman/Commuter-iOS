//
//  SelectOrigViewController.swift
//  Commuter
//
//  Created by Will Gilman on 12/4/18.
//  Copyright © 2018 BGHFM. All rights reserved.
//

import UIKit
import NotificationBannerSwift

class SelectOrigViewController: UIViewController {

    @IBOutlet weak var stationTableView: UITableView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var pickerContainerView: UIView!
    @IBOutlet weak var stationPickerView: UIPickerView!
    @IBOutlet weak var selectButton: UIButton!
    
    var activityAnimation: UIActivityIndicatorView!
    var stations = [Station]()
    var selectedStation: Station?
    var gradient: CAGradientLayer!
    var rowHeight: CGFloat = 80
    var currentRow: Int = 0
    var priorRow: Int = 0
    var centerRowOffset: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let stationCell = UINib(nibName: "StationCell", bundle: nil)
        stationTableView.register(stationCell, forCellReuseIdentifier: "StationCell")
        stationTableView.delegate = self
        stationTableView.dataSource = self
        stationTableView.rowHeight = rowHeight
        stationTableView.separatorStyle = .none
        stationTableView.showsVerticalScrollIndicator = false
//        stationTableView.contentInset.top = rowHeight * 2
        
        gradient = CAGradientLayer()
        gradient.delegate = self
        gradient.frame = stationTableView.bounds
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor, UIColor.black.cgColor, UIColor.clear.cgColor]
        gradient.locations = [0, 0.4, 0.6, 1]
        stationTableView.layer.mask = gradient
        
        activityAnimation = UIActivityIndicatorView(style: .whiteLarge)
        stationTableView.isHidden = true
        containerView.addSubview(activityAnimation)
        activityAnimation.color = AppColor.MediumGray.color
        activityAnimation.startAnimating()
        
        selectButton.setTitle("Next", for: .normal)
        selectButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        selectButton.backgroundColor = AppColor.Blue.color
        selectButton.tintColor = UIColor.white
        selectButton.layer.cornerRadius = 20
        selectButton.layer.shadowColor = AppColor.Blue.color.cgColor
        selectButton.layer.shadowOffset = CGSize(width: 0, height: 8)
        selectButton.layer.shadowOpacity = 1
        selectButton.layer.shadowRadius = 8
        
        loadStations()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        activityAnimation.center = containerView.convert(containerView.center, from: containerView.superview)
        updateGradientFrame()
    }
    
    func updateGradientFrame() {
        gradient.frame = CGRect(
                x: 0,
                y: stationTableView.contentOffset.y,
                width: stationTableView.bounds.width,
                height: stationTableView.bounds.height
        )
    }
    
    func loadStations() {
        CommuterAPI.sharedClient.getStations(success: { (stations) in
            AppVariable.stations = stations
            self.stations = stations
            self.stationTableView.reloadData()
            if let firstRow = self.stationTableView.indexPathsForVisibleRows?.first?.row {
                if let lastRow = self.stationTableView.indexPathsForVisibleRows?.last?.row {
                    self.centerRowOffset = (firstRow + lastRow) / 4
                }
            }
            self.activityAnimation.stopAnimating()
            self.stationTableView.isHidden = false
            guard let startingRow = stations.firstIndex(where: { (station) -> Bool in
                station.code == "PHIL"
            }) else {
                self.selectedStation = self.stations[0]
                return
            }
            self.selectedStation = self.stations[startingRow]
//            let indexPath = IndexPath(row: startingRow, section: 0)
//            self.stationTableView.selectRow(at: indexPath, animated: false, scrollPosition: .middle)
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
        let banner = NotificationBanner(title: "No Connection", subtitle: "We couldn't load your stations. Tap here to try again.", style: .warning)
        banner.autoDismiss = false
        banner.onTap = {
            self.activityAnimation.startAnimating()
            self.loadStations()
        }
        banner.show()
    }
}

extension SelectOrigViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = stationTableView.dequeueReusableCell(withIdentifier: "StationCell", for: indexPath) as! StationCell
        cell.station = stations[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedStation = stations[indexPath.row]
        return
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = scrollView.contentOffset.y + scrollView.contentInset.top + rowHeight / 2
        let cellIndex = floor(y / rowHeight)
        let centerCellIndex = Int(cellIndex) + centerRowOffset
        priorRow = currentRow
        currentRow = centerCellIndex
        // Highlight current row.
        let currentCell = stationTableView.cellForRow(at: IndexPath(row: currentRow, section: 0)) as! StationCell
        currentCell.inCenter = true
        // Un-highlight prior row
        if priorRow != currentRow {
            if let priorCell = stationTableView.cellForRow(at: IndexPath(row: priorRow, section: 0)) as? StationCell {
                priorCell.inCenter = false
            }
        }
        updateGradientFrame()
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let y = targetContentOffset.pointee.y + scrollView.contentInset.top + rowHeight / 2
        let cellIndex  = floor(y / rowHeight)
        targetContentOffset.pointee.y = cellIndex * rowHeight - scrollView.contentInset.top
    }
}

extension SelectOrigViewController: CALayerDelegate {
    
    func action(for layer: CALayer, forKey event: String) -> CAAction? {
        return NSNull()
    }
}
