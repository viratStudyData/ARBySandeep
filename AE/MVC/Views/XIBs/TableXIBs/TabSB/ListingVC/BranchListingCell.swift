//
//  BranchListingCell.swift
//  AE
//
//  Created by MAC_MINI_6 on 28/05/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

class BranchListingCell: UITableViewCell, ReusableCell {
  
  @IBOutlet weak var imgView: UIImageView!
  @IBOutlet weak var lblTitle: UILabel!
  @IBOutlet weak var lblAddress: UILabel!
  @IBOutlet weak var lblEmail: UILabel!
  @IBOutlet weak var lblCall: UILabel!
  @IBOutlet weak var imgMainBranch: UIImageView!
  
  var item: Any? {
    didSet {
      let business = item as? Business
      lblTitle.text = /business?.name
      lblAddress.text = /business?.addressDetails?.address
      lblEmail.text = /business?.email
      lblCall.text = "+\(/business?.contactDetails?.countryCode)-\(/business?.contactDetails?.phoneNo)"
      imgView.setImageKF(business?.imageUrl?.thumbnail)
      imgMainBranch.isHidden = !(/business?.isMasterBranch)
    }
  }
  
}
