//
//  HomeFriendCell.swift
//  AE
//
//  Created by MAC_MINI_6 on 08/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

class HomeFriendCell: UICollectionViewCell, ReusableCell {

  @IBOutlet weak var imgView: UIImageView!
  @IBOutlet weak var lblName: UILabel!
  @IBOutlet weak var lblDistance: UILabel!

  var item: Any? {
    didSet {
      let obj = item as? UserData
      imgView.setImageKF(obj?.imageUrl?.thumbnail)
      lblName.text = /obj?.name
      lblDistance.text = String(format: VCLiteral.DISTANCE_KM.localized, arguments: [/obj?.distance])
    }
  }
  
}
