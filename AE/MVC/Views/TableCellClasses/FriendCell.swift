//
//  FriendCell.swift
//  AE
//
//  Created by MAC_MINI_6 on 29/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

class FriendCell: UITableViewCell, ReusableCell {
  
  @IBOutlet weak var imgView: UIImageView!
  @IBOutlet weak var lblName: UILabel!
  @IBOutlet weak var btnUnfriend: UIButton!
  
  var friendRemoved: ( (_ friend: UserData?) -> Void )?
  
  var item: Any? {
    didSet {
      let user = item as? UserData
      imgView.setImageKF(user?.imageUrl?.thumbnail, placeHolder: #imageLiteral(resourceName: "ic_profile_placeholder"))
      lblName.text = /user?.name
    }
  }
  
  @IBAction func btnUnfriendAction(_ sender: Any) {
    UIApplication.topVC()?.alertBoxOKCancel(title: "", message: String.init(format: VCLiteral.UNFRIEND_ALERT.localized, /(item as? UserData)?.name), tapped: { [weak self] in
      self?.unfriendUserAPI()
      }, cancelTapped: { })
  }
  
  private func unfriendUserAPI() {
    btnUnfriend.isUserInteractionEnabled = false
    let user = item as? UserData
    EP_Other.unfriendUser(userId: /user?._id).request(success: { [weak self] (response) in
      self?.btnUnfriend.isUserInteractionEnabled = true
      self?.friendRemoved?(self?.item as? UserData)
    }) { [weak self] (error) in
      self?.btnUnfriend.isUserInteractionEnabled = true
    }
  }
}
