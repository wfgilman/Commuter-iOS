//
//  AppStoreReviewManager.swift
//  Commuter
//
//  Created by Will Gilman on 5/1/19.
//  Copyright © 2019 BGHFM. All rights reserved.
//

import Foundation
import StoreKit

enum AppStoreReviewManager {
    
    static let minimumSessionCount: Int = 5
    
    static func requestReviewIfAppropriate() {
        let defaults = UserDefaults.standard
        var sessionCount = defaults.integer(forKey: "SessionCount")
        sessionCount += 1
        print(sessionCount)
        UserDefaults.standard.set(sessionCount, forKey: "SessionCount")
        
        guard sessionCount >= minimumSessionCount else {
            return
        }
        
        let bundleVersionKey = kCFBundleVersionKey as String
        let currentVersion = Bundle.main.object(forInfoDictionaryKey: bundleVersionKey) as? String
        let lastVersion = defaults.string(forKey: "LastReviewRequestAppVersion")
        
        guard lastVersion == nil || lastVersion != currentVersion else {
            return
        }
        
        SKStoreReviewController.requestReview()
        defaults.set(0, forKey: "SessionCount")
        defaults.set(currentVersion, forKey: "LastReviewRequestAppVersion")
    }
}
