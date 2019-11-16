//
//  FriendListingCell.swift
//  AE
//
//  Created by MAC_MINI_6 on 10/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

class FriendListingCell: UITableViewCell, ReusableCell {
  @IBOutlet weak var imgView: UIImageView!
  @IBOutlet weak var lblTitle: UILabel!
  @IBOutlet weak var btnNav: UIButton!
  
  var item: Any? {
    didSet {
      let user = item as? UserData
      imgView.setImageKF(user?.imageUrl?.thumbnail)
      lblTitle.text = /user?.name
    }
  }
  
  @IBAction func btnNavAction(_ sender: UIButton) {
    
  }
  
    
}
