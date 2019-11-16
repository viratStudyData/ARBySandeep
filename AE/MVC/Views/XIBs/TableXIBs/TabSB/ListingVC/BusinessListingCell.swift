//
//  BusinessListingCell.swift
//  AE
//
//  Created by MAC_MINI_6 on 10/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

class BusinessListingCell: UITableViewCell, ReusableCell {

  @IBOutlet weak var imgView: UIImageView!
  @IBOutlet weak var lblTitle: UILabel!
  @IBOutlet weak var lblSubTitle: UILabel!
  @IBOutlet weak var btnNav: UIButton!
  
  var item: Any? {
    didSet {
      let business = item as? Business
      imgView.setImageKF(business?.logoUrl?.thumbnail)
      lblTitle.text = /business?.name
      lblSubTitle.text = /business?.businessType
    }
  }
  
  
  @IBAction func btnNavigationAction(_ sender: Any) {
    let business = (item as? Business)
    UIApplication.topVC()?.navigate(lat: /business?.addressDetails?.coordinates?.last, lng: /business?.addressDetails?.coordinates?.first)
  }
}
