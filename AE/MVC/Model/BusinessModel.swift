//
//  BusinessModel.swift
//  AE
//
//  Created by MAC_MINI_6 on 26/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import Foundation

class BusineesPageObject: Codable {
  var count: Int?
  var data: [Business]?
  
}

class Business: Codable {
  var name: String?
  var isMasterBranch: Bool?
  var isAdminVerified: Bool?
  var description: String?
  var socialLinks: SocialLinks?
  var contactDetails: PhoneNumber?
  var logoUrl: ImageURL?
  var imageUrl: ImageURL?
  var _id: String?
  var galleryCount: Int?
  var noOfBranches: Int?
  var language: String?
  var objectCount: Int?
  var objects: [Object]?
  var email: String?
  var addressDetails: AddressDetails?
  var gallery: [Gallery]?
  var packages: [Package]?
  var packageCount: Int?
  var businessType: String?
  var isFollowing: Bool?
  var masterBranchId: String?
  var distance: String?
  
  init() {
    
  }
}

extension Business: Equatable {
  static func == (lhs: Business, rhs: Business) -> Bool {
    return /lhs._id == /rhs._id
  }
}



class SocialLinks: Codable {
  var twitter: String?
  var facebook: String?
  var instagram: String?
  var snapchat: String?
}

class AddressDetails: Codable {
  var address: String?
  var city: String?
  var country: String?
  var coordinates: [Double]?
}

class Gallery: Codable {
  var _id: String?
  var fileUrl: ImageURL?
}

class Object: Codable, Equatable {
  var _id: String?
  var name: String?
  var description: String?
  var triggerType: String?
  var objectUrl: ImageURL?
  var coordinates: [Double]?
  var imageUrl: [ImageURL]?
  var objectLink: String?
  var packageId: Package?
  var businessId: Business?
  //
  var downloadValues: DownloadValues?
  //New Keys
  var mediaType: MediaType_AE?
  var mediaUrlSigned: ImageURL?
  
  static func == (lhs: Object, rhs: Object) -> Bool {
    return /lhs._id == /rhs._id
  }
}

class DownloadValues: Codable {
  var progress: Float?
  var downloadSpeed: Float?
  var downloadUnit: String?
  
  init(downloadModel: MZDownloadModel) {
    progress = downloadModel.progress
    downloadSpeed = downloadModel.speed?.speed
    downloadUnit = downloadModel.speed?.unit
  }
  
}

class Package: Codable, Equatable {
 
  var _id: String?
  var name: String?
  var description: String?
  var imageUrl: ImageURL?
  var noOfObjects: Int?
  var objects: [Object]?
  var businessId: Business?
  
  //
  var downloadStatus: DownloadStatus?

  static func == (lhs: Package, rhs: Package) -> Bool {
    return /lhs._id == /rhs._id
  }
  
}
