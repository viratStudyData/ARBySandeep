//
//  SearchUserCell.swift
//  AE
//
//  Created by MAC_MINI_6 on 24/05/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

class SearchUserCell: UITableViewCell, ReusableCell {
  
  @IBOutlet weak var imgView: UIImageView!
  @IBOutlet weak var lblName: UILabel!
  @IBOutlet weak var btnInvite: UIButton!
  @IBOutlet weak var btnWidth: NSLayoutConstraint!
  
  var item: Any? {
    didSet {
      let obj = item as? UserData
      let status = InviteStatus(rawValue: /obj?.status) ?? .ADD_FRIEND
      imgView.setImageKF(obj?.imageUrl?.thumbnail, placeHolder: #imageLiteral(resourceName: "ic_profile_placeholder"))
      lblName.text = /obj?.name
      btnInvite.setTitle(status.title, for: .normal)
      btnWidth.constant = status.btnWidth
    }
  }
  
  @IBAction func btnInviteAction(_ sender: UIButton) {
    if !CommonFuncs.shared.isUserLoggedIn(showPopUp: true, canBeCancelled: true) {
      return
    }
    
    let status = InviteStatus(rawValue: /(item as? UserData)?.status) ?? .INVITE
    switch status {
    case .ADD_FRIEND, .REJECTED, .UNFRIEND:
      sendRequestAPI()
    case .REQUESTED, .INVITE:
      break
    case .ACCEPTED:
      UIApplication.topVC()?.alertBoxOKCancel(title: "", message: String.init(format: VCLiteral.UNFRIEND_ALERT.localized, /(item as? UserData)?.name), tapped: { [weak self] in
        self?.unfriendUserAPI()
      }, cancelTapped: { })
    }
  }
  
  private func unfriendUserAPI() {
    btnInvite.isUserInteractionEnabled = false
    let user = item as? UserData
    EP_Other.unfriendUser(userId: /user?._id).request(success: { [weak self] (response) in
      self?.btnInvite.isUserInteractionEnabled = true
      (self?.item as? UserData)?.status = InviteStatus.ADD_FRIEND.rawValue
      (self?.superview as? UITableView)?.reloadData()
    }) { [weak self] (error) in
      self?.btnInvite.isUserInteractionEnabled = true
    }
  }
  
  private func sendRequestAPI() {
    btnInvite.isUserInteractionEnabled = false
    let user = item as? UserData
    EP_Other.sendRequest(id: /user?._id).request(success: { [weak self] (response) in
      self?.btnInvite.isUserInteractionEnabled = true
      (self?.item as? UserData)?.status = InviteStatus.REQUESTED.rawValue
      (self?.superview as? UITableView)?.reloadData()
    }) { [weak self] (_) in
      self?.btnInvite.isUserInteractionEnabled = true
    }
  }
}
