//
//  UIPanGestureExtensions.swift
//  AE
//
//  Created by MAC_MINI_6 on 05/07/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

public enum Direction: Int {
  case Up
  case Down
  case Left
  case Right
  
  public var isX: Bool { return self == .Left || self == .Right }
  public var isY: Bool { return !isX }
}

public extension UIPanGestureRecognizer {
  
  var direction: Direction? {
    let velocityValue = velocity(in: view)
    let vertical = abs(velocityValue.y) > abs(velocityValue.x)
    switch (vertical, velocityValue.x, velocityValue.y) {
    case (true, _, let y) where y < 0: return .Up
    case (true, _, let y) where y > 0: return .Down
    case (false, let x, _) where x > 0: return .Right
    case (false, let x, _) where x < 0: return .Left
    default: return nil
    }
  }
}
