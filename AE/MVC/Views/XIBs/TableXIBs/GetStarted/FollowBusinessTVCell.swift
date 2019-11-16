//
//  FollowBusinessTVCell.swift
//  AE
//
//  Created by MAC_MINI_6 on 04/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

class FollowBusinessTVCell: UITableViewCell, ReusableCell {
  
  
  @IBOutlet weak var imgView: UIImageView!
  @IBOutlet weak var lblTitle: UILabel!
  @IBOutlet weak var lblSubTitle: UILabel!
  @IBOutlet weak var btnFollow: UIButton!
  @IBOutlet weak var btnWidth: NSLayoutConstraint!
  
  var btnType = FollowUnfollow.Follow
  var didTapFollowUnfollow: (() -> ())?
  
  var item: Any? {
    didSet {
      let business = item as? Business
      btnType = (/business?.isFollowing).followUnfollowBtnType
      imgView.setImageKF(business?.logoUrl?.original)
      lblTitle.text = /business?.name
      lblSubTitle.text = /business?.businessType
      btnFollow.borderWidth = btnType.borderWidth
      btnFollow.borderColor = btnType.borderColor
      btnWidth.constant = btnType.btnWidth
      btnFollow.setTitle(btnType.title.localized, for: .normal)
      DispatchQueue.main.async { [weak self] in
        self?.btnFollow.backgroundColor = self?.btnType.btnColor
        self?.btnFollow.setTitleColor(self?.btnType.textColor, for: .normal)
      }
    }
  }
  
  @IBAction func btnFollowAction(_ sender: UIButton) {
    didTapFollowUnfollow?()
  }
  
}
