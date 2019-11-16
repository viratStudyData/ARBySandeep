//
//  HomeSection.swift
//  AE
//
//  Created by MAC_MINI_6 on 08/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

class HomeSection: UITableViewHeaderFooterView, ReusableHeaderFooter {
  @IBOutlet weak var lblTitle: UILabel!
  @IBOutlet weak var lblSubtitle: UILabel!
  @IBOutlet weak var btnViewAll: UIButton!
  
  typealias T = HeaderFooterData
  
  var business: Business?
  
  var item: HeaderFooterData? {
    didSet {
      lblTitle.text = /item?.other?.title
      lblSubtitle.text = /item?.other?.subTitle
      btnViewAll.isHidden = !(/item?.other?.isViewAllVisible)
    }
  }
  
  @IBAction func btnViewAllAction(_ sender: Any) {
    let listingVC = StoryboardScene.Other.ListingVC.instantiate()
    switch /item?.other?.title {
    case VCLiteral.NEARBY_FRIENDS.localized:
      listingVC.listingType = .NearbyFriends
      UIApplication.topVC()?.pushVC(listingVC)
    case VCLiteral.NEARBY_EXPERIENCES.localized:
      listingVC.listingType = .NearbyBusiness
      UIApplication.topVC()?.pushVC(listingVC)
    case VCLiteral.BUSINESS_DETAIL_PACKAGE_TITLE.localized:
      listingVC.listingType = .BusinessDetailPackages(by: business)
      UIApplication.topVC()?.pushVC(listingVC)
    case VCLiteral.BUSINESS_DETAIL_OBJECTS_TITLE.localized:
      listingVC.listingType = .BusinessDetailObjects(by: business)
      UIApplication.topVC()?.pushVC(listingVC)
    case VCLiteral.BUSINESS_DETAIL_GALLERY_TITLE.localized:
      let galleryVC = StoryboardScene.Other.GalleryVC.instantiate()
      galleryVC.business = business
      UIApplication.topVC()?.pushVC(galleryVC)
    default:
      break
    }
  }
}
