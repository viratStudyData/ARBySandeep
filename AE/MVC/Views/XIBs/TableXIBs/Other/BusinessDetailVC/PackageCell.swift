//
//  PackageCell.swift
//  AE
//
//  Created by MAC_MINI_6 on 15/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

class PackageCell: UITableViewCell, ReusableCell {
  
  @IBOutlet weak var imgMain: UIImageView!
  @IBOutlet weak var imgLogo: UIImageView!
  @IBOutlet weak var lblTitle: UILabel!
  @IBOutlet weak var lblSubtitle: UILabel!
  
  var item: Any? {
    didSet {
      let obj = item as? Package
      imgMain.setImageKF(obj?.imageUrl?.thumbnail)
      imgLogo.setImageKF(obj?.imageUrl?.thumbnail)
      lblTitle.text = /obj?.name
      lblSubtitle.text = /obj?.description
    }
  }
  
  var downloadedItem: Package? {
    didSet {
      lblTitle.text = /downloadedItem?.name
      lblSubtitle.text = /downloadedItem?.description
      DownloadPreference.shared.getImageFrom(path: "\(MZUtility.baseFilePath)/\(/downloadedItem?.imageUrl?.fileName)", localImage: { [weak self] (localImage) in
        self?.imgMain.image = localImage
        self?.imgLogo.image = localImage
      })
    }
  }
}
