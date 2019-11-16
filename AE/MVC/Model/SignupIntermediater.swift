//
//  SignupIntermediater.swift
//  AE
//
//  Created by MAC_MINI_6 on 16/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import Foundation

class SignupIntermediater {
  var signUpBy: SignupBy = .PHONE_NUMBER
  var name: String?
  var emailPhone: String?
  var iso: String?
  var password: String?
  var profilePicURL: String?
  
  init(_ _name: String?, _ _emailPhone: String?, _ _iso: String?) {
    signUpBy = /_emailPhone?.isNumeric ? .PHONE_NUMBER : .EMAIL
    name = _name
    emailPhone = _emailPhone
    iso = _iso
  }
  
}
