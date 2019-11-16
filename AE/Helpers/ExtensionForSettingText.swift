//
//  IntExtension.swift
//  AE
//
//  Created by MAC_MINI_6 on 02/05/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

extension Int {
  var branchesTitle: String {
    if self == 0 {
      return ""
    } else if self == 1 {
      return VCLiteral.BRANCH.localized
    } else {
      return VCLiteral.BRANCHES.localized
    }
  }
}

extension Bool {
  var followUnfollowText: String {
    return self ? VCLiteral.UNFOLLOW.localized : VCLiteral.FOLLOW.localized
  }
}
