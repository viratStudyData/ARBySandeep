//
//  BusinessDetailObjCell.swift
//  AE
//
//  Created by MAC_MINI_6 on 15/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

class BusinessDetailObjCell: UICollectionViewCell, ReusableCell {
  
  @IBOutlet weak var imgView: UIImageView!
  @IBOutlet weak var indicator: UIActivityIndicatorView!
  
  var item: Any? {
    didSet {
      let object = item as? Object
//      imgView.setImageKF(object?.objectUrl?.thumbnail)
      
      switch object?.mediaType ?? .OBJECT {
      case .OBJECT:
        imgView.setImageKF(object?.objectUrl?.thumbnail)

        handleStatus(status: object?.objectUrl?.downloadStatus ?? .NONE)
      default:
        imgView.setImageKF(object?.mediaUrlSigned?.thumbnail)

        handleStatus(status: object?.mediaUrlSigned?.downloadStatus ?? .NONE)
      }
      
//      switch object?.objectUrl?.downloadStatus ?? .NONE {
//      case .NONE:
//        indicator.isHidden = true
//      case .DOWNLOADING, .PENDING:
//        indicator.startAnimating()
//        indicator.isHidden = false
//      case .DOWNLOADED:
//        indicator.isHidden = true
//        indicator.stopAnimating()
//      default:
//        indicator.isHidden = true
//      }
    }
  }

  func handleStatus(status: DownloadStatus) {
    switch status {
    case .NONE:
      indicator.isHidden = true
    case .DOWNLOADING, .PENDING:
      indicator.startAnimating()
      indicator.isHidden = false
    case .DOWNLOADED:
      indicator.isHidden = true
      indicator.stopAnimating()
    default:
      indicator.isHidden = true
    }
  }
  
}
