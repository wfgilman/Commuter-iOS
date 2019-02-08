//
//  ETA.swift
//  Commuter
//
//  Created by Will Gilman on 1/24/19.
//  Copyright © 2019 BGHFM. All rights reserved.
//

import Foundation
import Unbox

class ETA: Unboxable {
    var nextStation: Station
    var nextStationEtaMin: Int
    var eta: Date
    var etaMin: Int
    
    required init(unboxer: Unboxer) throws {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        
        nextStation = try unboxer.unbox(key: "next_station")
        nextStationEtaMin = try unboxer.unbox(key: "next_station_eta_min")
        eta = try unboxer.unbox(key: "eta", formatter: dateFormatter)
        etaMin = try unboxer.unbox(key: "eta_min")
    }
}
