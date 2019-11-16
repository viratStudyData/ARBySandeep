//
//  SearchLayout.swift
//  AE
//
//  Created by MAC_MINI_6 on 24/05/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import Foundation

extension HeaderFooterData {
  
  class func getSearchResults(_ response: MapData?) -> [HeaderFooterData] {
    
    var items = [HeaderFooterData]()
    let businesses = Array(response?.businessData?.prefix(10) ?? [])
    let users = Array(response?.userData?.prefix(10) ?? [])
    
    let sectionBusiness = HeaderFooterData(_property: HeaderFooterValues.init(headerIdentifier: SearchSection.identfier, headerHeight: 40, cellIdentifier: SearchBusinessCell.identfier, cellHeight: 64, footerIdentifier: "", footerHeight: 0.0001),
                                           _items: businesses,
                                           _other: OtherHeaderFooterProperty(title: VCLiteral.SEARCH_SECTION_BUSINESS.localized, subTitle: "", isViewAllVisible: /response?.businessCount > 10))
    
    let sectionUsers = HeaderFooterData(_property: HeaderFooterValues.init(headerIdentifier: SearchSection.identfier, headerHeight: 40, cellIdentifier: SearchUserCell.identfier, cellHeight: 48.0, footerIdentifier: "", footerHeight: 0.0001),
                                        _items: users,
                                        _other: OtherHeaderFooterProperty(title: VCLiteral.SEARCH_SECTION_FRIENDS.localized, subTitle: "", isViewAllVisible: /response?.userCount > 10))
    if businesses.count > 0 {
      items.append(sectionBusiness)
    }
    
    if users.count > 0 {
      items.append(sectionUsers)
    }
    return items
    
  }
  
}
