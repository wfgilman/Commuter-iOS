//
//  Departure.swift
//  Commuter
//
//  Created by Will Gilman on 12/2/18.
//  Copyright © 2018 BGHFM. All rights reserved.
//

import UIKit
import Unbox

class Departure: Unboxable {
    var tripId: Int
    var std: Date
    var etd: Date
    var etdMin: Int
    var delayMin: Int
    var eta: Date
    var durationMin: Int
    var length: Int?
    var headsign: String
    var stops: Int
    var priorStops: Int
    private var routeHexColor: String
    var routeColor: UIColor
    var isEmpty: Bool
    
    required init(unboxer: Unboxer) throws {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"

        tripId = try unboxer.unbox(key: "trip_id")
        std = try unboxer.unbox(key: "std", formatter: dateFormatter)
        etd = try unboxer.unbox(key: "etd", formatter: dateFormatter)
        etdMin = try unboxer.unbox(key: "etd_min")
        delayMin = try unboxer.unbox(key: "delay_min")
        eta = try unboxer.unbox(key: "eta", formatter: dateFormatter)
        durationMin = try unboxer.unbox(key: "duration_min")
        length = unboxer.unbox(key: "length")
        headsign = try unboxer.unbox(key: "headsign")
        stops = try unboxer.unbox(key: "stops")
        priorStops = try unboxer.unbox(key: "prior_stops")
        routeHexColor = try unboxer.unbox(key: "route_hex_color")
        routeColor = UIColor(hex: UInt32(routeHexColor, radix: 16)!)
        isEmpty = (priorStops == 0)
    }
    
    class func withArray(dictionaries: [Dictionary<String, Any>]) throws -> [Departure] {
        var departures = [Departure]()
        for d in dictionaries {
            let departure: Departure = try unbox(dictionary: d)
            departures.append(departure)
        }
        return departures
    }
}
