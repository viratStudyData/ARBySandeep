//
//  User.swift
//  AE
//
//  Created by MAC_MINI_6 on 16/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import Foundation


public class Safe<Base: Decodable>: Decodable {
  
  public let value: Base?
  
  required public init(from decoder: Decoder) throws {
    do {
      let container = try decoder.singleValueContainer()
      self.value = try container.decode(Base.self)
    } catch {
      assertionFailure("ERROR: \(error)")
      // TODO: automatically send a report about a corrupted data
      self.value = nil
    }
  }
}

class CommonModel<T: Codable>: Codable {
  var meta: Meta?
  var data: T?
}

class Meta: Codable {
  var type: String?
  var statusCode: Int?
  var message: String?
  
}

class UserData: Codable {
  var isFollowBusiness: Bool?
  var accessToken: String?
  var signUpBy: String?
  var createdDate: Double?
  var OTPcode: String?
  var isBlocked: Bool?
  var _id: String?
  var isDeleted: Bool?
  var isVerified: Bool?
  var isInviteSent: Bool?
  var isRequestAccepted: Bool?
  var latLong: [Double]?
  var name: String?
  var phoneNumber: PhoneNumber?
  var showLocation: ShowLocationType?
  var email: String?
  var imageUrl: ImageURL?
  var isLoginFromFB: Bool?
  var followingBusinessCount: Int?
  var friendsCount: Int?
  var status: String?
  var messageCount: Int?
  var distance: String?
  
  var isSelected: Bool?
  var currentArea: String?
  
  
}

extension UserData: Equatable {
  static func == (lhs: UserData, rhs: UserData) -> Bool {
    return /lhs._id == /rhs._id
  }
}

class PhoneNumber: Codable {
  var countryCode: String?
  var phoneNo: String?
  var ISO: String?
  
}

class ImageURL: Codable {
  var original: String?
  var thumbnail: String?
  var type: MediaType_AE?
  var objectId: String?
  var fileName: String?
  var thumbnailName: String?
//  var textureName: String?
//  var textureFileImage: String?
  var glb: String?
  var gltf: String?
  
  //
  var downloadStatus: DownloadStatus?

  
  init(_ url: String?) {
    original = url
    thumbnail = url
  }
}
