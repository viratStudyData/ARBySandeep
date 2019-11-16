//
//  ScreenSize.swift
//  AE
//
//  Created by MAC_MINI_6 on 08/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

struct ScreenSize {
  static let SCREEN_WIDTH = UIScreen.main.bounds.size.width
  static let SCREEN_HEIGHT = UIScreen.main.bounds.size.height
  static let SCREEN_MAX_LENGTH = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
  static let SCREEN_MIN_LENGTH = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
  static let SCALE = UIScreen.main.scale
}

struct TableHeight {
//HomeBusinessCell Ratio = 375 / (144 + 20 20 Up bottom gaps)
  static let HomeBusinessCell = ScreenSize.SCREEN_WIDTH * (184 / 375)
  static let HomeHeader: CGFloat = 64.0
  static let BusinessDetailHeader: CGFloat = 80.0
  static let zeroForHeaderFooter: CGFloat = 0.0001
  static let HomeFriendCell: CGFloat =  192.0
  static let PackageCell: CGFloat = (ScreenSize.SCREEN_WIDTH - 48) * ((176.0 + 16.0) / 328.0)
  static let DownloadedObject: CGFloat = ScreenSize.SCREEN_WIDTH * (144 / 375)
  static let BranchListingCell: CGFloat = ScreenSize.SCREEN_WIDTH * (154 / 375)
  static let PackageDetailCell: CGFloat = ScreenSize.SCREEN_WIDTH * (168 / 375)

  static let BusinessObjects: CGFloat = CollectionSize.BusinessObjects.width + 8 + 24
  static let BusineesGallery: CGFloat = CollectionSize.BusinessGallery.width + 8 + 24
  static let BusinessDetailTableViewHeader_MAX: CGFloat = ScreenSize.SCREEN_WIDTH * (226 / 375)
  static let BusinessDetailTableViewHeader_MIN: CGFloat = UIApplication.statusBarHeight + 44.0
}

struct CollectionSize {
  static let BusinessGallery: CGSize = CGSize.init(width: (ScreenSize.SCREEN_WIDTH - 72) / 4, height: (ScreenSize.SCREEN_WIDTH - 72) / 4)
  
  static let GalleryVCSize: CGSize = CGSize(width: (ScreenSize.SCREEN_WIDTH - 72) / 3, height: (ScreenSize.SCREEN_WIDTH - 72) / 3)
  
  static let BusinessObjects: CGSize = CGSize.init(width: (ScreenSize.SCREEN_WIDTH - 72) / 3.40, height: (ScreenSize.SCREEN_WIDTH - 72) / 3.40)
}
