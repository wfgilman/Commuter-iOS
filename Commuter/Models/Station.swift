//
//  Station.swift
//  Commuter
//
//  Created by Will Gilman on 12/2/18.
//  Copyright © 2018 BGHFM. All rights reserved.
//

import UIKit
import Unbox

class Station: Unboxable {
    var code: String
    var name: String
    
    required init(unboxer: Unboxer) throws {
        code = try unboxer.unbox(key: "code")
        name = try unboxer.unbox(key: "name")
    }
    
    class func withArray(dictionaries: [Dictionary<String, Any>]) throws -> [Station] {
        var stations = [Station]()
        for d in dictionaries {
            let station: Station = try unbox(dictionary: d)
            stations.append(station)
        }
        return stations
    }
}
