//
//  SettingCellBold.swift
//  AE
//
//  Created by MAC_MINI_6 on 17/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

class SettingCellBold: UITableViewCell, ReusableCell {

  @IBOutlet weak var lblTitle: UILabel!
  
  var item: Any? {
    didSet {
      lblTitle.text = /(item as? Setting)?.title?.localized
    }
  }
  
}
