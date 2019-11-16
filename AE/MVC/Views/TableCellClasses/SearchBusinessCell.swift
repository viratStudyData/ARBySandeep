//
//  SearchBusinessCell.swift
//  AE
//
//  Created by MAC_MINI_6 on 24/05/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

class SearchBusinessCell: UITableViewCell, ReusableCell {

  @IBOutlet weak var imgView: UIImageView!
  @IBOutlet weak var lblBusinessName: UILabel!
  @IBOutlet weak var lblBusinessType: UILabel!
  
  var item: Any? {
    didSet {
      let obj = item as? Business
      imgView.setImageKF(obj?.logoUrl?.thumbnail)
      lblBusinessName.text = /obj?.name
      lblBusinessType.text = /obj?.businessType
    }
  }
  
}
