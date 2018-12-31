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
    var id: Int
    var code: String
    var name: String
    var dictionary: [String : Any] {
        return ["id" : id, "code": code, "name" : name]
    }
    
    required init(unboxer: Unboxer) throws {
        id = try unboxer.unbox(key: "id")
        code = try unboxer.unbox(key: "code")
        name = try unboxer.unbox(key: "name")
    }
    
    class func fromDict(dict: Dictionary<String, Any>) throws -> Station {
        return try unbox(dictionary: dict)
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
