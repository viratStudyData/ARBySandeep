//
//  UnfollowPopUpVC.swift
//  AE
//
//  Created by MAC_MINI_6 on 27/05/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

class UnfollowPopUpVC: UIViewController {

  @IBOutlet weak var imgView: UIImageView!
  @IBOutlet weak var lblAlert: UILabel!
  
  var business: Business?
  var didTapYes: (() -> Void)?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    imgView.setImageKF(business?.logoUrl?.thumbnail)
    lblAlert.text = "Are you sure you want to unfollow \(/business?.name) ?"
    startPopUpWithAnimation()
  }

  @IBAction func btnAction(_ sender: UIButton) {
    switch sender.tag {
    case 0: //Cancel
      removePopUp()
    case 1: //Yes
      removePopUp()
      didTapYes?()
    default:
      break
    }
  }
  
}
