//
//  ImageCell.swift
//  AE
//
//  Created by MAC_MINI_6 on 15/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

class ImageCell: UICollectionViewCell, ReusableCell {
  
  @IBOutlet weak var imgView: UIImageView!
  @IBOutlet weak var imgPlay: UIImageView!
  @IBOutlet weak var lbl360: UILabel!
  
  var item: Any? {
    didSet {
      let obj = item as? Gallery
      imgView.setImageKF(obj?.fileUrl?.thumbnail)
      let mediaType = obj?.fileUrl?.type ?? .IMAGE
      switch mediaType {
      case .IMAGE:
        imgPlay.isHidden = true
        lbl360.isHidden = true
      case .VIDEO:
        imgPlay.isHidden = false
        lbl360.isHidden = true
      case .VIDEO360, .IMAGE360:
        imgPlay.isHidden = false
        lbl360.isHidden = false
      case .OBJECT:
        break
      }
    }
  }

}
