//
//  ExpandedTouchAreaButton.swift
//  Commuter
//
//  Created by Will Gilman on 2/2/19.
//  Copyright © 2019 BGHFM. All rights reserved.
//

import UIKit

@IBDesignable
class ExpandedTouchAreaButton: UIButton {

    @IBInspectable var margin: CGFloat = 20.0
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        //increase touch area for control in all directions by 20
        
        let rect = CGRect(origin: self.bounds.origin, size: self.bounds.size)
        let area = rect.insetBy(dx: -margin, dy: -margin)
        return area.contains(point)
    }

}
