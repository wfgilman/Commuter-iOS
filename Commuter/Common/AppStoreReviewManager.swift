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
    
    static let minAppStoreReviewActionCount: Int = 10
    
    static func requestReviewIfAppropriate() {
        let defaults = UserDefaults.standard
        var appStoreReviewActionCount = defaults.integer(forKey: "AppStoreReviewActionCount")
        appStoreReviewActionCount += 1
        UserDefaults.standard.set(appStoreReviewActionCount, forKey: "AppStoreReviewActionCount")
        
        guard appStoreReviewActionCount >= minAppStoreReviewActionCount else {
            return
        }
        
        let bundleVersionKey = kCFBundleVersionKey as String
        let currentVersion = Bundle.main.object(forInfoDictionaryKey: bundleVersionKey) as? String
        let lastVersion = defaults.string(forKey: "LastReviewRequestAppVersion")
        
        guard lastVersion == nil || lastVersion != currentVersion else {
            defaults.set(0, forKey: "AppStoreReviewActionCount")
            return
        }
        
        SKStoreReviewController.requestReview()
        defaults.set(0, forKey: "SessionCount")
        defaults.set(currentVersion, forKey: "LastReviewRequestAppVersion")
    }
}
