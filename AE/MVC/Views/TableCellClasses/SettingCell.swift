//
//  SettingCell.swift
//  AE
//
//  Created by MAC_MINI_6 on 12/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

class SettingCell: UITableViewCell, ReusableCell {
  @IBOutlet weak var imgView: UIImageView!
  @IBOutlet weak var lblTitle: UILabel!
  @IBOutlet weak var viewCount: UIView!
  @IBOutlet weak var lblCount: UILabel!
  
  
  var item: Any? {
    didSet {
      let data = (item as? ProfileCellData)
      imgView.image = data?.image
      lblTitle.text = /data?.title?.localized
      lblCount.text = "\(/data?.count)"
      viewCount.isHidden = /data?.count == 0
    }
  }
  

}
