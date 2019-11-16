//
//  DownloadedObjectCell.swift
//  AE
//
//  Created by MAC_MINI_6 on 12/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

class DownloadedObjectCell: UITableViewCell, ReusableCell {
  
  @IBOutlet weak var imgView: UIImageView!
  @IBOutlet weak var lblTitle: UILabel!
  @IBOutlet weak var lblDesc: UILabel!
  @IBOutlet weak var btnOptions: UIButton!
  @IBOutlet weak var lblRadius: UILabel!
  
  var btnOptionsTapped: (() -> Void)?
  
  var item: Any? {
    didSet {
      let obj = item as? Object
      switch obj?.mediaType ?? .OBJECT {
      case .OBJECT:
        DownloadPreference.shared.getImageFrom(path: "\(MZUtility.baseFilePath)/\(/obj?.objectUrl?.thumbnailName)", localImage: { [weak self] (localImage) in
          self?.imgView.image = localImage
        })
      default:
        DownloadPreference.shared.getImageFrom(path: "\(MZUtility.baseFilePath)/\(/obj?.mediaUrlSigned?.fileName)", localImage: { [weak self] (localImage) in
          self?.imgView.image = localImage
        })
      }
      
      lblTitle.text = /obj?.name
      lblDesc.text = /obj?.description
      lblRadius.text = ""
      lblDesc.isUserInteractionEnabled = true
      lblDesc.addGestureRecognizer(UILongPressGestureRecognizer.init(target: self, action: #selector(longPress(gesture:))))

    }
  }
  
  
  @objc func longPress(gesture: UILongPressGestureRecognizer) {
    switch gesture.state {
    case .began:
      UIApplication.topVC()?.alertWithDesc(desc: /(item as? Object)?.description)
    default:
      break
    }
  }
  
  @IBAction func btnOptionAction(_ sender: UIButton) {
    btnOptionsTapped?()
  }
  
}
