//
//  BusinessDetailLayout.swift
//  AE
//
//  Created by MAC_MINI_6 on 13/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

extension HeaderFooterData {
  
  class func getBusinessDetailData(_ business: Business, _ isInitalSetup: Bool? = false) -> [HeaderFooterData] {
    var sectionalData = [HeaderFooterData]()
    
    let objects = DownloadPreference.shared.getSyncedObjectsForStatus(backendObjects: business.objects)
    
    let section1TopDetail = HeaderFooterData.init(_property:  HeaderFooterValues.init(headerIdentifier: "", headerHeight: 0.0001, cellIdentifier: BusinessTopDetailCell.identfier, cellHeight: UITableView.automaticDimension, footerIdentifier: LineHeaderFooter.identfier, footerHeight: 2),
                                                   _items: [business],
                                                   _other: nil)
    
    let section2Gallery = HeaderFooterData.init(_property: HeaderFooterValues.init(headerIdentifier: HomeSection.identfier, headerHeight: TableHeight.BusinessDetailHeader, cellIdentifier: HorizontalCollectionCell.identfier, cellHeight: TableHeight.BusineesGallery, footerIdentifier: LineHeaderFooter.identfier, footerHeight: 2),
                                                _items: [GalleryImages.init(backendArray: Array((business.gallery ?? []).prefix(4)))], _other: OtherHeaderFooterProperty.init(title: VCLiteral.BUSINESS_DETAIL_GALLERY_TITLE.localized, subTitle: VCLiteral.BUSINESS_DETAIL_GALLERY_SUBS.localized, isViewAllVisible: /business.galleryCount > 4))
    
    let section3ARPackages = HeaderFooterData.init(_property: HeaderFooterValues.init(headerIdentifier: HomeSection.identfier, headerHeight: TableHeight.BusinessDetailHeader, cellIdentifier: PackageCell.identfier, cellHeight: TableHeight.PackageCell, footerIdentifier: LineHeaderFooter.identfier, footerHeight: 16.0),
                                                   _items: Array((business.packages ?? []).prefix(3)), _other: OtherHeaderFooterProperty.init(title: VCLiteral.BUSINESS_DETAIL_PACKAGE_TITLE.localized, subTitle: VCLiteral.BUSINESS_DETAIL_PACKAGE_SUBS.localized, isViewAllVisible: /business.packageCount > 3))
    
    let section4_3DObjects = HeaderFooterData.init(_property: HeaderFooterValues.init(headerIdentifier: HomeSection.identfier, headerHeight: TableHeight.BusinessDetailHeader, cellIdentifier: HorizontalCollectionCell.identfier, cellHeight: TableHeight.BusinessObjects, footerIdentifier: LineHeaderFooter.identfier, footerHeight: 2),
                                                   _items: [BusinessDetail_3DObjects.init(backendArray: Array(objects.prefix(4)))], _other: OtherHeaderFooterProperty.init(title: VCLiteral.BUSINESS_DETAIL_OBJECTS_TITLE.localized, subTitle: VCLiteral.BUSINESS_DETAIL_OBJECTS_SUBS.localized, isViewAllVisible: /business.objectCount > 4))
    
    let section5SocialLinks = HeaderFooterData.init(_property: HeaderFooterValues.init(headerIdentifier: HomeSection.identfier, headerHeight: TableHeight.BusinessDetailHeader, cellIdentifier: SocialLinksCell.identfier, cellHeight: UITableView.automaticDimension, footerIdentifier: LineHeaderFooter.identfier, footerHeight: 2),
                                                    _items: [business], _other: OtherHeaderFooterProperty.init(title: VCLiteral.BUSINESS_DETAIL_CONNECT_TITLE.localized, subTitle: String(format: VCLiteral.BUSINESS_DETAIL_CONNECT_SUBS.localized, arguments: [/business.name]), isViewAllVisible: false))
    
    if /isInitalSetup {
      sectionalData = [section1TopDetail]
    } else {
      sectionalData = [section1TopDetail]
      if /business.galleryCount > 0 {
        sectionalData.append(section2Gallery)
      }
      if /business.packageCount > 0 {
        sectionalData.append(section3ARPackages)
      }
      if /business.objectCount > 0 {
        sectionalData.append(section4_3DObjects)
      }
      
      if !(/business.socialLinks?.twitter == "" &&
          /business.socialLinks?.facebook == "" &&
          /business.socialLinks?.instagram == "" &&
          /business.socialLinks?.snapchat == "") {
        sectionalData.append(section5SocialLinks)
      }
      
//      if business.socialLinks != nil {
//      }
    }
    return sectionalData
  }
  
  
}


class GalleryImages {
  var items: [Gallery]?
  
  init(backendArray: [Gallery]?) {
    items = backendArray
  }
}

class BusinessDetail_3DObjects {
  var items: [Object]?
  
  init(backendArray: [Object]?) {
    items = backendArray
  }
}


