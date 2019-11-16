//
//  UserInviteTVCell.swift
//  AE
//
//  Created by MAC_MINI_6 on 04/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

class UserInviteTVCell: UITableViewCell, ReusableCell {

  @IBOutlet weak var imgView: UIImageView!
  @IBOutlet weak var lblName: UILabel!
  @IBOutlet weak var btnInvite: UIButton!
  @IBOutlet weak var btnWidth: NSLayoutConstraint!
  
  lazy var phoneServices: PhoneServices = {
    let phoneServicesInstance = PhoneServices()
    return phoneServicesInstance
  }()
  
  var item: Any? {
    didSet {
      if let contact = item as? ContactNumber {
        let status = InviteStatus(rawValue: /contact.number?.status)
        lblName.text = /contact.name
        imgView.image = contact.image
        btnInvite.setTitle(/status?.title, for: .normal)
        btnWidth.constant = /status?.btnWidth
      }
    }
  }
  
  @IBAction func btnInviteAction(_ sender: UIButton) {
    let status = InviteStatus(rawValue: /(item as? ContactNumber)?.number?.status) ?? .INVITE
    switch status {
    case .ADD_FRIEND, .REJECTED, .UNFRIEND:
      sendRequestAPI()
    case .INVITE:
      //Invite
      phoneServices.sendMessage(to: [/(item as? ContactNumber)?.number?.phoneNo], messageBody: "Please join me on Augmented Experience app as @\(/UserPreference.shared.data?.name)")
    case .REQUESTED:
      break
    case .ACCEPTED:
      unfriendAPI()
    }
  }
  
  private func unfriendAPI() {
    btnInvite.isUserInteractionEnabled = false
    let contact = item as? ContactNumber
    EP_Other.unfriendUser(userId: /contact?.number?.id).request(success: { [weak self] (response) in
      self?.btnInvite.isUserInteractionEnabled = true
      (self?.item as? ContactNumber)?.number?.status = InviteStatus.ADD_FRIEND.rawValue
      (self?.superview as? UITableView)?.reloadData()
    }) { [weak self] (error) in
      self?.btnInvite.isUserInteractionEnabled = true
    }
    
  }
  
  private func sendRequestAPI() {
    btnInvite.isUserInteractionEnabled = false
    let contact = item as? ContactNumber
    EP_Other.sendRequest(id: contact?.number?.id).request(success: { [weak self] (response) in
      self?.btnInvite.isUserInteractionEnabled = true
      (self?.item as? ContactNumber)?.number?.status = InviteStatus.REQUESTED.rawValue
      (self?.superview as? UITableView)?.reloadData()
    }) { [weak self] (_) in
      self?.btnInvite.isUserInteractionEnabled = true
    }
  }
  
}
