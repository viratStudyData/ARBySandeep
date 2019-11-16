//
//  SocialLinksCell.swift
//  AE
//
//  Created by MAC_MINI_6 on 15/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

class SocialLinksCell: UITableViewCell, ReusableCell {
  
  @IBOutlet var viewArray: [UIView]!
  
  var item: Any? {
    didSet {
      let links = (item as? Business)?.socialLinks
      viewArray.first(where: {$0.tag == 0 })?.isHidden = /links?.twitter == ""
      viewArray.first(where: {$0.tag == 1 })?.isHidden = /links?.facebook == ""
      viewArray.first(where: {$0.tag == 2 })?.isHidden = /links?.instagram == ""
      viewArray.first(where: {$0.tag == 3 })?.isHidden = /links?.snapchat == ""
    }
  }
  
  @IBAction func btnAction(_ sender: UIButton) { // Tags Twitter 0, FB 1, Insta 2, Snap 3
    switch sender.tag {
    case 0: // Twitter
      if let url = URL(string: /(item as? Business)?.socialLinks?.twitter) {
        UIApplication.shared.open(url, options: [:],completionHandler: nil)
      }
    case 1: // Facebook
      if let url = URL(string: /(item as? Business)?.socialLinks?.facebook) {
        UIApplication.shared.open(url, options: [:],completionHandler: nil)
      }
    case 2: // Instagram
      if let url = URL(string: /(item as? Business)?.socialLinks?.instagram) {
        UIApplication.shared.open(url, options: [:],completionHandler: nil)
      }
    case 3: // Snapchate
      if let url = URL(string: /(item as? Business)?.socialLinks?.snapchat) {
        UIApplication.shared.open(url, options: [:],completionHandler: nil)
      }
    default:
      break
    }
  }
  
}
