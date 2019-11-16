//
//  ProfileLayout.swift
//  AE
//
//  Created by MAC_MINI_6 on 12/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

class ProfileCellData {
  var title: VCLiteral?
  var image: UIImage?
  var count: Int?
  var isRedShown: Bool = false
  
  init(_ _title: VCLiteral?, _ _image: UIImage?, _ _count: Int?, _ _isRedShown: Bool) {
    title = _title
    image = _image
    count = _count
    isRedShown = _isRedShown
  }
}



extension HeaderFooterData {
  
  class func getProfileData() -> [HeaderFooterData] {
    let userData = UserPreference.shared.data
    
    let sectionOneData = [ProfileCellData(.PROFILE_CELL_TITLE_FOLLOWING, #imageLiteral(resourceName: "ic_following"), Int(/userData?.followingBusinessCount), false),
                          ProfileCellData(.PROFILE_CELL_TITLE_FRIENDS, #imageLiteral(resourceName: "ic_friends"), Int(/userData?.friendsCount), false),
                          ProfileCellData(.PROFILE_CELL_TITLE_MESSAGES, #imageLiteral(resourceName: "ic_messages"), Int(/userData?.messageCount), false),
                          ProfileCellData(.PROFILE_CELL_TITLE_INVITEFRIENDS, #imageLiteral(resourceName: "ic_invite"), 0, false)]
    
    let sectionTwoData = [ProfileCellData(.PROFILE_CELL_TITLE_SETTINGS, #imageLiteral(resourceName: "ic_settings"), 0, false),
                          ProfileCellData(.PROFILE_CELL_TITLE_SIGNOUT, #imageLiteral(resourceName: "ic_logout"), 0, false)]
    
    let items = [HeaderFooterData.init(_property: HeaderFooterValues.init(headerIdentifier: LineHeaderFooter.identfier, headerHeight: 2.0, cellIdentifier: SettingCell.identfier, cellHeight: 64.0, footerIdentifier: "", footerHeight: 0.0001),
                                       _items: sectionOneData,
                                       _other: nil),
                 HeaderFooterData.init(_property: HeaderFooterValues.init(headerIdentifier: LineHeaderFooter.identfier, headerHeight: 2.0, cellIdentifier: SettingCell.identfier, cellHeight: 64.0, footerIdentifier: "", footerHeight: 0.0001),
                                       _items: sectionTwoData,
                                       _other: nil)]
    
    return items
  }
  
}
