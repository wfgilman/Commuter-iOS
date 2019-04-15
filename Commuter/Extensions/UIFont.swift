//
//  UIFont.swift
//  Commuter
//
//  Created by Will Gilman on 12/9/18.
//  Copyright © 2018 BGHFM. All rights reserved.
//

import UIKit

extension UIFont {
    
    class func myBlackSystemFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.black, size: size)!
    }
    
    class func mySystemFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.regular, size: size)!
    }
//
//    class func myBoldSystemFont(ofSize size: CGFloat) -> UIFont {
//        return UIFont(name: AppFontName.bold, size: size)!
//    }
//
//    class func mySemiboldSystemFont(ofSize size: CGFloat) -> UIFont {
//        return UIFont(name: AppFontName.semibold, size: size)!
//    }
//
//    class func myHeavySystemFont(ofSize size: CGFloat) -> UIFont {
//        return UIFont(name: AppFontName.heavy, size: size)!
//    }
//
//    class func myLightSystemFont(ofSize size: CGFloat) -> UIFont {
//        return UIFont(name: AppFontName.light, size: size)!
//    }
}
