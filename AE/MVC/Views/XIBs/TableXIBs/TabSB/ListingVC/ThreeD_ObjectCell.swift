//
//  ThreeD_ObjectVC.swift
//  AE
//
//  Created by MAC_MINI_6 on 25/05/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

class ThreeD_ObjectCell: UITableViewCell, ReusableCell {
  
  @IBOutlet weak var imgView: UIImageView!
  @IBOutlet weak var lblTitle: UILabel!
  @IBOutlet weak var lblDesc: UILabel!
  @IBOutlet weak var lblRadius: UILabel!
  @IBOutlet weak var btnDownload: UIButton!
  @IBOutlet weak var progressView: UIProgressView!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  
  @objc func longPress(gesture: UILongPressGestureRecognizer) {
    switch gesture.state {
    case .began:
      UIApplication.topVC()?.alertWithDesc(desc: /(item as? Object)?.description)
    default:
      break
    }
  }
  
  var item: Any? {
    didSet {
      let obj = item as? Object
      
      
      
      lblTitle.text = /obj?.name
      lblDesc.text = /obj?.description
      lblDesc.isUserInteractionEnabled = true
      lblDesc.addGestureRecognizer(UILongPressGestureRecognizer.init(target: self, action: #selector(longPress(gesture:))))
      
      
      if /obj?.coordinates?.count == 0 {
        lblRadius.isHidden = true
      } else {
        lblRadius.isHidden = false
      }
      
      switch obj?.mediaType ?? .OBJECT {
      case .OBJECT:
        imgView.setImageKF(obj?.objectUrl?.thumbnail)
        switchDownloadStatus(status: obj?.objectUrl?.downloadStatus ?? .NONE)
      default:
        imgView.setImageKF(obj?.mediaUrlSigned?.thumbnail)
        switchDownloadStatus(status: obj?.mediaUrlSigned?.downloadStatus ?? .NONE)
      }
    }
  }

  func switchDownloadStatus(status: DownloadStatus) {
    let obj = item as? Object

    switch status {
    case .NONE:
      btnDownload.isHidden = false
      progressView.isHidden = true
      activityIndicator.isHidden = true
    case .DOWNLOADING, .PENDING:

      
      btnDownload.isHidden = true
      progressView.isHidden = false
      
      progressView.setProgress(/obj?.downloadValues?.progress, animated: true)
      lblRadius.isHidden = false
      lblRadius.text = "\(/obj?.downloadValues?.downloadSpeed?.rounded(toPlaces: 2)) \(/obj?.downloadValues?.downloadUnit)/s"
      activityIndicator.isHidden = false
      activityIndicator.startAnimating()
    case .DOWNLOADED:

      btnDownload.isHidden = true
      progressView.isHidden = true
      if /obj?.coordinates?.count == 0 {
        lblRadius.isHidden = true
      } else {
        lblRadius.isHidden = false
      }
      activityIndicator.isHidden = true
      activityIndicator.stopAnimating()
    default:

      activityIndicator.isHidden = true
      
      btnDownload.isHidden = false
      progressView.isHidden = true
      if /obj?.coordinates?.count == 0 {
        lblRadius.isHidden = true
      } else {
        lblRadius.isHidden = false
      }
    }
  }
  
}
