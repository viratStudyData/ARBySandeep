//
//  SettingDetailLayout.swift
//  AE
//
//  Created by MAC_MINI_6 on 17/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

enum ShowLocationType: String, Codable {
  case CONTACTS_ONLY = "CONTACTS_ONLY"
  case EVERYONE = "EVERYONE"
  case NONE = "NONE"
}

extension HeaderFooterData {
  
  class func getSettingsData() -> [HeaderFooterData] {
    
    let locationType : ShowLocationType = UserPreference.shared.data?.showLocation ?? .NONE
    
    let section1 = HeaderFooterData.init(_property: HeaderFooterValues.init(headerIdentifier: ShowLocationHeader.identfier, headerHeight: 56.0, cellIdentifier: SettingCellRegular.identfier, cellHeight: 56.0, footerIdentifier: "", footerHeight: 0.0001),
                                         _items: [Setting(VCLiteral.SETTING_CONTACTS_ONLY),
                                                  Setting(VCLiteral.SETTING_EVERYONE)], _other: nil)
    let section2 = HeaderFooterData.init(_property: HeaderFooterValues.init(headerIdentifier: "", headerHeight: 0.0001, cellIdentifier: SettingCellBold.identfier, cellHeight: 56.0, footerIdentifier: "", footerHeight: 0.0001),
                                         _items: [Setting(VCLiteral.SETTING_EDIT_PROFILE),
                                                  Setting(VCLiteral.SETTING_CHANGE_PASSWORD),
                                                  Setting(VCLiteral.SETTING_CONTACT_US),
                                                  Setting(VCLiteral.SETTING_ABOUT)],
                                         _other: nil)
    
    if locationType == .NONE {
      section1.items  = []
    }
    if /UserPreference.shared.data?.isLoginFromFB {
      section2.items?.remove(at: 1)
    }
    
    return [section1, section2]
  }
  
}

class Setting {
  var title: VCLiteral?
  var isSelected: Bool = false
  
  init(_ _title: VCLiteral?) {
    title = _title
  }
}
