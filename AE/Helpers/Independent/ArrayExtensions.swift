//
//  ArrayExtensions.swift
//  AE
//
//  Created by MAC_MINI_6 on 04/06/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import Foundation

extension Array where Element: Equatable {
  func containSameElements(_ array: [Element]) -> Bool {
    var selfCopy = self
    var secondArrayCopy = array
    while let currentItem = selfCopy.popLast() {
      if let indexOfCurrentItem = secondArrayCopy.firstIndex(of: currentItem) {
        secondArrayCopy.remove(at: indexOfCurrentItem)
      } else {
        return false
      }
    }
    return secondArrayCopy.isEmpty
  }
  
  func removeDuplicates() -> [Element] {
    var result = [Element]()
    
    for value in self {
      if result.contains(value) == false {
        result.append(value)
      }
    }
    
    return result
  }
}
