//
//  Color.swift
//  AE
//
//  Created by MAC_MINI_6 on 18/03/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

enum Color: String {
  case backgroundWhite = "backgroundWhite"
  case navigationItem = "navigationItem"
  case navigationBarTint = "navigationBarTint"
  case buttonBlue = "buttonBlue"
  case btnFB = "btnFB"
  case textBlack = "textBlack"
  case textBlack40 = "textBlack40"
  case textBlue = "textBlue"
  case textWhite = "textWhite"
  case gradient1 = "gradient1"
  case gradient2 = "gradient2"
  case success = "success"
  case textBlack90 = "textBlack90"
  case text282828_90 = "text282828_90"
  case notification = "notification"
  
  var value: UIColor {
    return UIColor(named: self.rawValue) ?? UIColor()
  }
}

