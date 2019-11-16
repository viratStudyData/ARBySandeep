//
//  MapModel.swift
//  AE
//
//  Created by MAC_MINI_6 on 21/05/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import Foundation

class MapData: Codable {
  var globalData: [GlobalPlace]?
  var userData: [UserData]?
  var businessData: [Business]?
  var nextPage: Bool?
  var latLong: [Double]?
  var radius: Double?
  var nextPageUrl: String?
  var userCount: Int?
  var businessCount: Int?
  
}

class GlobalPlace: Codable, Equatable {
  var _id: String?
  var name: String?
  var location: PlaceLocation?
  var imageUrl: ImageURL?
  
  static func == (lhs: GlobalPlace, rhs: GlobalPlace) -> Bool {
    return /lhs._id == /rhs._id
  }
}

class PlaceLocation: Codable {
  var address: String?
  var lat: Double?
  var long: Double?
  
}

class MixedMapData: Equatable {
  var markerType: MarkerType = MarkerType.Business
  var user: UserData?
  var business: Business?
  var globalPlace: GlobalPlace?
  
  init(_ _markerType: MarkerType, _ _user: UserData?, _ _business: Business?, _ _globalPlace: GlobalPlace?) {
    markerType = _markerType
    user = _user
    business = _business
    globalPlace = _globalPlace
  }
  
  class func getMixedDataNewItemsOnly(_ previousItems: [MixedMapData]?, _ apiData: MapData?) -> [MixedMapData] {
    var items = [MixedMapData]()
    apiData?.businessData?.forEach { items.append(MixedMapData(.Business, nil, $0, nil)) }
    apiData?.userData?.forEach { items.append(MixedMapData(.User, $0, nil, nil)) }
    apiData?.globalData?.forEach { items.append(MixedMapData(.GlobalPlace, nil, nil, $0)) }
    
    let newItems = items.filter { !(/previousItems?.contains($0)) }
    
    return newItems
  }
  
  static func == (lhs: MixedMapData, rhs: MixedMapData) -> Bool {
    switch lhs.markerType {
    case .Business:
      return lhs.markerType == rhs.markerType && /lhs.business?._id == /rhs.business?._id
    case .GlobalPlace:
      return lhs.markerType == rhs.markerType && /lhs.globalPlace?._id == /rhs.globalPlace?._id
    case .User:
      return lhs.markerType == rhs.markerType && /lhs.user?._id == /rhs.user?._id
    }
  }
}


enum MarkerType: Int {
  case GlobalPlace
  case Business
  case User
}
