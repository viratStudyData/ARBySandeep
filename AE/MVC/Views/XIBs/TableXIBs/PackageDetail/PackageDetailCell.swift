//
//  PackageDetailCell.swift
//  AE
//
//  Created by MAC_MINI_6 on 29/05/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

class PackageDetailCell: UITableViewCell, ReusableCell {
  
  @IBOutlet weak var imgView: UIImageView!
  @IBOutlet weak var lblTitle: UILabel!
  @IBOutlet weak var lblExpire: UILabel!
  @IBOutlet weak var lblDesc: UILabel!
  @IBOutlet weak var btnDwnld: UIButton!
  
  @IBAction func btnDwnldAction(_ sender: Any) {
    
  }
  
  @objc func longPress(gesture: UILongPressGestureRecognizer) {
    switch gesture.state {
    case .began:
      UIApplication.topVC()?.alertWithDesc(desc: /(item as? Package)?.description)
    default:
      break
    }
  }
  
  var isDownloaded: Bool?
  
  var item: Any? {
    didSet {
      let package = item as? Package
      if /isDownloaded {
        DownloadPreference.shared.getImageFrom(path: "\(MZUtility.baseFilePath)/\(/package?.imageUrl?.fileName)", localImage: { [weak self] (localImage) in
          self?.imgView.image = localImage
        })
      } else {
        imgView.setImageKF(package?.imageUrl?.thumbnail)
      }
      lblTitle.text = /package?.name
      lblExpire.text = ""
      lblDesc.text = /package?.description
      
      lblDesc.isUserInteractionEnabled = true
      lblDesc.addGestureRecognizer(UILongPressGestureRecognizer.init(target: self, action: #selector(longPress(gesture:))))
    }
  }
}
