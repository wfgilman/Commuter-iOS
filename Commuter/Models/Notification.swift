//
//  Notification.swift
//  Commuter
//
//  Created by Will Gilman on 12/30/18.
//  Copyright © 2018 BGHFM. All rights reserved.
//

import Foundation
import Unbox

class Notification: Unboxable {
    var id: Int
    var descrip: String
    
    required init(unboxer: Unboxer) throws {
        id = try unboxer.unbox(key: "id")
        descrip = try unboxer.unbox(key: "descrip")
    }
    
    class func withArray(dictionaries: [Dictionary<String, Any>]) throws -> [Notification] {
        var notifications = [Notification]()
        for d in dictionaries {
            let notification: Notification = try unbox(dictionary: d)
            notifications.append(notification)
        }
        return notifications
    }
}
