//
//  PackageDetailLayout.swift
//  AE
//
//  Created by MAC_MINI_6 on 29/05/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import Foundation

extension HeaderFooterData {
  
  class func getPackageDetailListing(package: Package?, objects: [Object]?, isDownloaded: Bool?) -> [HeaderFooterData] {
    var itemsToReturn = [HeaderFooterData]()
    
    if let pack = package {
      let headerFooterValues = HeaderFooterValues(headerIdentifier: "",
                                 headerHeight: 0.0001,
                                 cellIdentifier: PackageDetailCell.identfier,
                                 cellHeight: TableHeight.PackageDetailCell,
                                 footerIdentifier: "",
                                 footerHeight: 0.0001)
      
      let sectionPackageDetail = HeaderFooterData(_property: headerFooterValues, _items: [pack], _other: nil)
      itemsToReturn.append(sectionPackageDetail)
    }
    
    if /objects?.count > 0 {
      let headerFooterValues = HeaderFooterValues(headerIdentifier: PackageDetailSectionView.identfier,
                                                  headerHeight: 48.0,
                                                  cellIdentifier: /isDownloaded ? DownloadedObjectCell.identfier : ThreeD_ObjectCell.identfier,
                                                  cellHeight: TableHeight.DownloadedObject,
                                                  footerIdentifier: "",
                                                  footerHeight: 0.0001)
      let sectionObjectsDetail = HeaderFooterData(_property: headerFooterValues, _items: objects, _other: nil)
      itemsToReturn.append(sectionObjectsDetail)
    }
    return itemsToReturn
  }
  
}
