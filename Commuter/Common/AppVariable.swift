//
//  AppVariable.swift
//  Commuter
//
//  Created by Will Gilman on 12/5/18.
//  Copyright © 2018 BGHFM. All rights reserved.
//

import Foundation

struct AppVariable {
    static var stations = [Station]()
    static let duration: TimeInterval = 0.36
//    static let baseURL = "http://localhost:4000/api/v1"
    static let baseURL = "https://commuter.gigalixirapp.com/api/v1"
    static var deviceId: String?
}
