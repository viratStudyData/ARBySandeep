//
//  UIButtonExtensions.swift
//  AE
//
//  Created by MAC_MINI_6 on 25/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

extension UIButton {
  @IBInspectable
  open var exclusiveTouchEnabled : Bool {
    get {
      return self.isExclusiveTouch
    }
    set(value) {
      self.isExclusiveTouch = value
    }
  }
}
