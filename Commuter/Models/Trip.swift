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
    var departure: [Departure]
    
    required init(unboxer: Unboxer) throws {
        orig = try unboxer.unbox(key: "orig")
        dest = try unboxer.unbox(key: "dest")
        departure = try unboxer.unbox(key: "departures")
    }
}
