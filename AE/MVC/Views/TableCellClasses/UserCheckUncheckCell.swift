//
//  UserCheckUncheckCell.swift
//  AE
//
//  Created by MAC_MINI_6 on 22/06/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

class UserCheckUncheckCell: UITableViewCell, ReusableCell {

  @IBOutlet weak var imgView: UIImageView!
  @IBOutlet weak var lblTitle: UILabel!
  @IBOutlet weak var imgCheckUncheck: UIImageView!
  
  var item: Any? {
    didSet {
      let user = item as? UserData
      imgView.setImageKF(user?.imageUrl?.thumbnail, placeHolder: #imageLiteral(resourceName: "ic_profile_placeholder"))
      lblTitle.text = /user?.name
      imgCheckUncheck.image = /user?.isSelected ? #imageLiteral(resourceName: "ic_check-1") : #imageLiteral(resourceName: "ic_uncheck")
    }
  }
  
}
