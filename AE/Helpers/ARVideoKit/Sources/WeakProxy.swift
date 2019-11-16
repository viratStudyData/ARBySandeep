//
//  WeakProxy.swift
//  AE
//
//  Created by MAC_MINI_6 on 08/07/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import Foundation
class WeakProxy: NSObject {
  weak var target: NSObjectProtocol?
  
  init(target: NSObjectProtocol) {
    self.target = target
    super.init()
  }
  
  override func responds(to aSelector: Selector!) -> Bool {
    return (target?.responds(to: aSelector) ?? false) || super.responds(to: aSelector)
  }
  
  override func forwardingTarget(for aSelector: Selector!) -> Any? {
    return target
  }
}
