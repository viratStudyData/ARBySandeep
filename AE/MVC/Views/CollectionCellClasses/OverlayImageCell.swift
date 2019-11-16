//
//  OverlayImageCell.swift
//  AE
//
//  Created by MAC_MINI_6 on 01/08/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

class OverlayImageCell: UICollectionViewCell, ReusableCell {
  
  @IBOutlet weak var imgView: UIImageView!

  var item: Any? {
    didSet {
      
      if let image = item as? UIImage {
        imgView.image = image
      } else {
        let filter = item as? Filter
        imgView.setImageKF(filter?.imageUrl?.original)
      }
      
    }
  }
}
