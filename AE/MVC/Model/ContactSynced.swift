//
//  ContactSynced.swift
//  AE
//
//  Created by MAC_MINI_6 on 27/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import Foundation

class ContactSynced: Codable {
  var phoneNo: String?
  var ISO: String?
  var id: String?
  var status: String?
  var facebookId: String?
  var name: String?
  
  init(_ _phoneNo: String?, _ _iso: String?) {
    phoneNo = _phoneNo
    ISO = _iso
  }
  
  init() {
    
  }
}
