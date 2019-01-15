//
//  AppColor.swift
//  Commuter
//
//  Created by Will Gilman on 12/9/18.
//  Copyright © 2018 BGHFM. All rights reserved.
//

import UIKit

enum AppColor: UInt32 {
    
    case Charcoal = 0x1d2323
    case MediumGray = 0x939fae
    case PaleGray = 0xf4f5f6
    case Red = 0xd14836
    
    var color: UIColor {
        return UIColor(hex: rawValue)
    }
}

