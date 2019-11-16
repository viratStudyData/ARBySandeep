//
//  SettingCellRegular.swift
//  AE
//
//  Created by MAC_MINI_6 on 17/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

class SettingCellRegular: UITableViewCell, ReusableCell {
  
  @IBOutlet weak var lblTitle: UILabel!
  @IBOutlet weak var imgCheck: UIImageView!
  
  var item: Any? {
    didSet {
      lblTitle.text = /(item as? Setting)?.title?.localized
      let locationType = UserPreference.shared.data?.showLocation ?? .NONE
      let cellType = (item as? Setting)?.title ?? VCLiteral.SETTING_CONTACTS_ONLY
      switch cellType {
      case .SETTING_CONTACTS_ONLY:
        imgCheck.isHidden = locationType != .CONTACTS_ONLY
      case .SETTING_EVERYONE:
        imgCheck.isHidden = locationType != .EVERYONE
      default: break
      }
    }
  }

}
