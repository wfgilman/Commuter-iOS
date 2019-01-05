//
//  Trip.swift
//  Commuter
//
//  Created by Will Gilman on 12/3/18.
//  Copyright © 2018 BGHFM. All rights reserved.
//

import Foundation
import Unbox

class Trip: Unboxable {
    var orig: Station
    var dest: Station
    var asOf: Date
    var departures: [Departure]
    
    required init(unboxer: Unboxer) throws {
        orig = try unboxer.unbox(key: "orig")
        dest = try unboxer.unbox(key: "dest")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        asOf = try unboxer.unbox(key: "as_of", formatter: dateFormatter)
        departures = try unboxer.unbox(key: "departures")
    }
}
