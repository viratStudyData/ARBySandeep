//
//  InviteFriendModels.swift
//  AE
//
//  Created by MAC_MINI_6 on 04/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

class FriendToInvite {
  var facebookItem: Any?
  var contact: ContactNumber?
  var backendObj: ContactSynced? { // Contact from backend
    didSet {
      
    }
  }
  var isInDataBase: Bool = false

  init(_contact: ContactNumber?) {
    contact = _contact
  }

  init() {

  }
}
