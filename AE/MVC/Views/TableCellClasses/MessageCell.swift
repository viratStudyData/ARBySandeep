//
//  MessageCell.swift
//  AE
//
//  Created by MAC_MINI_6 on 29/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell, ReusableCell {
  
  @IBOutlet weak var imgView: UIImageView!
  @IBOutlet weak var lblName: UILabel!
  @IBOutlet weak var lblMessageType: UILabel!
  @IBOutlet weak var lblType: UILabel!
  @IBOutlet weak var btn: UIButton!
  
  
  var item: Any? {
    didSet {
      let message = item as? Message
      imgView.setImageKF(message?.senderId?.imageUrl?.thumbnail)
      lblName.text = /message?.senderId?.name
      lblMessageType.text = /message?.messageType?.title.localized
      btn.setTitle(/message?.messageType?.btnTitle.localized, for: .normal)
    }
  }
  
  @IBAction func btnAction(_ sender: UIButton) {
    let message = item as? Message
    switch message?.messageType ?? .IMAGE {
    case .IMAGE:
      let destVC = StoryboardScene.Other.MediaPreviewVC.instantiate()
      destVC.item = ([(message?.fileUrl)!], 0)
      UIApplication.topVC()?.pushVC(destVC)
    case .VIDEO:
      UIApplication.topVC()?.playVideo(URL(string: /message?.fileUrl?.original))
    default:
      break
    }
  }
  
}
