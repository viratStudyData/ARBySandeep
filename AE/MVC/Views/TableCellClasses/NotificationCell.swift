//
//  NotificationCell.swift
//  AE
//
//  Created by MAC_MINI_6 on 13/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

class NotificationCell: UITableViewCell, ReusableCell {
  
  @IBOutlet weak var imgView: UIImageView!
  @IBOutlet weak var lblTitle: UILabel!
  @IBOutlet weak var lblTime: UILabel!
  @IBOutlet weak var viewNotification: UIView!
  
  var item: Any? {
    didSet {
      let notification = item as? Notification
//      viewNotification.isHidden = /notification?.isRead
      viewNotification.backgroundColor = /notification?.isRead ? Color.textBlack40.value : Color.notification.value
      lblTime.text = Date.init(timeIntervalSince1970: Double(/notification?.createdDate) / 1000).relativeTimeToString()
      switch notification?.notificationType ?? .FRIEND_REQUEST {
      case .FRIEND_REQUEST,
           .REQUEST_ACCEPTED,
           .SENT_MESSAGE:
        imgView.setImageKF(/notification?.userId?.imageUrl?.thumbnail, placeHolder: #imageLiteral(resourceName: "ic_profile_placeholder"))
        lblTitle.text = "\(/notification?.userId?.name) \(/notification?.message)"
      case .NEAR_BY_BUSINESS:
        break
      case .NEAR_BY_OBJECT:
        break
      case .UPLOADED_OBJECT:
        break
      case .UPLOADED_PACKAGE:
        break
      case .ADMIN_NOTIFICATION:
        imgView.setImageKF(/notification?.userId?.imageUrl?.thumbnail, placeHolder: #imageLiteral(resourceName: "ic_profile_placeholder"))
        lblTitle.text = "\(/notification?.message)"
      }
    }
  }
  
  @IBAction func btnReadUnreadAction(_ sender: UIButton) {
    let notification = (item as? Notification)
    sender.isUserInteractionEnabled = false
    EP_Other.readUnreadNotification(id: notification?._id, status: /notification?.isRead ? .UNREAD : .READ).request(success: { [weak self] (response) in
      (self?.item as? Notification)?.isRead = !(/notification?.isRead)
      (UIApplication.topVC() as? NotificationVC)?.tableView.reloadData()
      sender.isUserInteractionEnabled = true
    }) { (error) in
      sender.isUserInteractionEnabled = true
    }
  }
  
}
