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
    var station: Station
    var eta: Date
    var etaMin: Int
    
    required init(unboxer: Unboxer) throws {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        
        station = try unboxer.unbox(key: "station")
        eta = try unboxer.unbox(key: "eta", formatter: dateFormatter)
        etaMin = try unboxer.unbox(key: "eta_min")
    }
}
