//
//  HomeBusinessCell.swift
//  AE
//
//  Created by MAC_MINI_6 on 08/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

class HomeBusinessCell: UICollectionViewCell, ReusableCell {

  @IBOutlet weak var imgView: UIImageView!
  @IBOutlet weak var imgViewBusinessLogo: UIImageView!
  @IBOutlet weak var lblTitle: UILabel!
  @IBOutlet weak var lblDistance: UILabel!
  
  var item: Any? {
    didSet {
      let data = item as? Business
      imgView.setImageKF(data?.imageUrl?.thumbnail)
      lblTitle.text = /data?.name
      imgViewBusinessLogo.setImageKF(data?.logoUrl?.thumbnail)
      lblDistance.text = String(format: VCLiteral.DISTANCE_KM.localized, arguments: [/data?.distance])
    }
  }
  
}
