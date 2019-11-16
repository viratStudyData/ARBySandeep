//
//  HomeLayout.swift
//  AE
//
//  Created by MAC_MINI_6 on 08/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

extension HeaderFooterData {

  class func getHomeItems(businessObj: BusineesPageObject?, freinds: [UserData]) -> [HeaderFooterData] {
    let business = businessObj?.data ?? []
    let maxBusiness = Array(business.prefix(3))
    let businesses = [HomeBusiness.init(maxBusiness)]
    let friendsList = [HomeFriend.init(Array(freinds.prefix(5)))]
    let sectionItems = [HeaderFooterData.init(_property: HeaderFooterValues.init(headerIdentifier: HomeSection.name, headerHeight: TableHeight.HomeHeader, cellIdentifier: HorizontalCollectionCell.name, cellHeight: TableHeight.HomeBusinessCell, footerIdentifier: "", footerHeight: TableHeight.zeroForHeaderFooter),
                                            _items: businesses,
                                            _other: OtherHeaderFooterProperty.init(title: VCLiteral.NEARBY_EXPERIENCES.localized, subTitle: VCLiteral.NEARBY_EXPERIENCES_SUBTITLE.localized, isViewAllVisible: /businessObj?.count > 3)),
                        
                        HeaderFooterData.init(_property: HeaderFooterValues.init(headerIdentifier: HomeSection.name, headerHeight: TableHeight.HomeHeader, cellIdentifier: HorizontalCollectionCell.name, cellHeight: TableHeight.HomeFriendCell, footerIdentifier: "", footerHeight: TableHeight.zeroForHeaderFooter),
                                        _items: friendsList,
                                        _other: OtherHeaderFooterProperty.init(title: VCLiteral.NEARBY_FRIENDS.localized, subTitle: VCLiteral.NEARBY_FRIENDS_SUBTITLE.localized, isViewAllVisible: freinds.count > 5))]
    return sectionItems
  }
  
}

class HomeBusiness {
  var items: [Business]?
  
  init(_ _items: [Business]?) {
    items = _items
  }
}

class HomeFriend {
  
  var items: [UserData]?
  
  init(_ _items: [UserData]?) {
    items = _items
  }
  
}

