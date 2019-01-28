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
    static let grantedNotificationAuth = NSNotification.Name("grantedNotificationAuth")
    
    static var deviceId: String? {
        get {
            return UserDefaults.standard.string(forKey: "DeviceToken")
        }
        set (newValue) {
            UserDefaults.standard.set(newValue, forKey: "DeviceToken")
        }
    }
    
    static var origStation: Station? {
        get {
            guard let origDict = UserDefaults.standard.dictionary(forKey: "OrigStation") else { return nil }
            do {
                return try Station.fromDict(dict: origDict)
            } catch {
                return nil
            }
        }
        set (newValue) {
            if let origDict = newValue?.dictionary {
                UserDefaults.standard.set(origDict, forKey: "OrigStation")
            }
        }
    }
    
    static var destStation: Station? {
        get {
            guard let destDict = UserDefaults.standard.dictionary(forKey: "DestStation") else { return nil }
            do {
                return try Station.fromDict(dict: destDict)
            } catch {
                return nil
            }
        }
        set (newValue) {
            if let destDict = newValue?.dictionary {
                UserDefaults.standard.set(destDict, forKey: "DestStation")
            }
        }
    }
    
    static var muted: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "Muted") 
        }
        set (newValue) {
            UserDefaults.standard.set(newValue, forKey: "Muted")
        }
    }
}
