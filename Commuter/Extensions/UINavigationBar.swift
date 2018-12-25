//
//  UINavigationBar.swift
//  Commuter
//
//  Created by Will Gilman on 12/9/18.
//  Copyright © 2018 BGHFM. All rights reserved.
//

import UIKit

extension UINavigationBar {
    
    func setup(titleColor: UIColor?, hasBottomBorder: Bool, isTranslucent: Bool) {
        self.tintColor = AppColor.Charcoal.color
        self.barTintColor = UIColor.white
        self.backIndicatorImage = UIImage(named: "left_chevron")
        self.backIndicatorTransitionMaskImage = UIImage(named: "left_chevron")
        if !hasBottomBorder {
            self.setBackgroundImage(UIImage(), for: .default)
            self.shadowImage = UIImage()
        } else {
            self.shadowImage = nil
        }
        self.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor : titleColor ?? UIColor.black,
            NSAttributedString.Key.font : UIFont.mySemiboldSystemFont(ofSize: 17)
        ]
        self.isTranslucent = isTranslucent
    }
}
