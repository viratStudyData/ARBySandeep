//
//  EP_Other.swift
//  AE
//
//  Created by MAC_MINI_6 on 26/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import Foundation
import Moya

enum EP_Other {
  case nearByBusiness(pageNo: String?, businessId: String?)
  case nearByFriends(pageNo: String?)
  case sendRequest(id: String?)
  case businessDetail(id: String?)
  case followUnfollowBusiness(id: String?, action: FollowAction?)
  case followedBusinesses(pageNo: String?)
  case userFriends(pageNo: String?, keyword: String?)
  case notifications(pageNo: String?)
  case mapDataListing(radius: String?, latitude: String?, longitude: String?, pageNo: String?, search: String?, flag: MapFlag, nextPageUrl: String?)
  case homeSearch(pageNo: String?, search: String?, flag: MapFlag)
  case contactUs(message: String?)
  case appDefaults
  case objectListing(objectId: String?, businessId: String?, packageId: String?, pageNo: String?)
  case packageListing(businessId: String?, packageId: String?, pageNo: String?)
  case getGallery(businessId: String?, pageNo: String?)
  case getProfile
  case downloadObject(objId: String?, packageId: String?)
  case acceptRejectRequest(id: String?, action: RequestAction)
  case unfriendUser(userId: String?)
  case messageListing(pageNo: String?)
  case uploadItem(item: ShareItemType?) //Consist of two api's on the basis of share type
  case readUnreadNotification(id: String?, status: NotificationStatus)
  case nearByBusinessFilters
}

extension EP_Other: TargetType, AccessTokenAuthorizable {
  var baseURL: URL {
    return URL(string: APIConstant.basePath)!
  }
  
  var path: String {
    switch self {
    case .nearByBusiness(_):
      return APIConstant.nearByBusiness
    case .nearByFriends(_):
      return APIConstant.nearByFriends
    case .sendRequest(_):
      return APIConstant.sendRequest
    case .businessDetail(_):
      return APIConstant.businessDetail
    case .followUnfollowBusiness(_):
      return APIConstant.followUnfollowBusiness
    case .followedBusinesses(_):
      return APIConstant.followedBusinesses
    case .userFriends(_):
      return APIConstant.userFriends
    case .notifications(_):
      return APIConstant.notifications
    case .mapDataListing(_):
      return APIConstant.mapDataListing
    case .homeSearch(_):
      return APIConstant.homeSearch
    case .contactUs(_):
      return APIConstant.contactUs
    case .appDefaults:
      return APIConstant.appDefaults
    case .objectListing(_):
      return APIConstant.objectListing
    case .packageListing(_):
      return APIConstant.packageListing
    case .getGallery(_):
      return APIConstant.getGallery
    case .getProfile:
      return APIConstant.getProfile
    case .downloadObject(_):
      return APIConstant.downloadObject
    case .acceptRejectRequest(_):
      return APIConstant.acceptRejectRequest
    case .unfriendUser(_):
      return APIConstant.unfriendUser
    case .uploadItem(let item):
      guard let itemType = item else { return "" }
      switch itemType {
      case .image(_):
        return APIConstant.uploadImage
      case .video(_):
        return APIConstant.uploadVideo
      }
    case .messageListing(_):
      return APIConstant.messageListing
    case .readUnreadNotification(_):
      return APIConstant.readUnreadNotification
    case .nearByBusinessFilters:
      return APIConstant.nearByBusinessFilters
    }
  }
  
  var method: Moya.Method {
    switch self {
    case .nearByBusiness(_),
         .nearByFriends(_),
         .businessDetail(_),
         .userFriends(_),
         .notifications(_),
         .mapDataListing(_),
         .homeSearch(_),
         .appDefaults,
         .objectListing(_),
         .packageListing(_),
         .getGallery(_),
         .getProfile,
         .messageListing(_),
         .nearByBusinessFilters:
      return .get
    default:
      return .post
    }
  }
  
  var sampleData: Data {
    return Data()
  }
  
  var multipartBody: [MultipartFormData]? {
    switch self {
    case .uploadItem(let item):
      var multiPartData = [MultipartFormData]()
      guard let uploadType = item else { return [] }
      
      switch uploadType {
      case .image(let uiImage):
        let data = uiImage.jpegData(compressionQuality: 0.5) ?? Data()
        multiPartData.append(MultipartFormData.init(provider: .data(data), name: "file", fileName: "fileImage.jpg", mimeType: "image/jpeg"))
      case .video(let localURL):
        guard let data = try? Data(contentsOf: localURL) else { return [] }
        multiPartData.append(MultipartFormData.init(provider: .data(data), name: "file", fileName: "fileImage.mp4", mimeType: "video/mp4"))
      }
      parameters?.forEach({ (key, value) in
        let tempValue = /(value as? String)
        let data = tempValue.data(using: String.Encoding.utf8) ?? Data()
        multiPartData.append(MultipartFormData.init(provider: .data(data), name: key))
      })
      return multiPartData
    default:
      return []
    }
  }
  
  var task: Task {
    switch self {
    case .uploadItem(_):
      return Task.uploadMultipart(multipartBody ?? [])
    default:
      return Task.requestParameters(parameters: parameters ?? [:], encoding: parameterEncoding)
    }
  }
  
  var headers: [String : String]? {
    switch self {
    case .appDefaults:
      return nil
    default:
      return ["Accept" : "application/json",
              "Authorization":"Bearer " + /UserPreference.shared.data?.accessToken]
    }
  }
  
  var authorizationType: AuthorizationType {
    return .bearer
  }
  
  //Custom Variables
  var parameters: [String: Any]? {
    let location = LocationManager.shared.locationData
    let latitude = String(location.latitude)
    let longitude = String(location.longitude)
    
    switch self {
    case .nearByBusiness(let pageNo, let businessId):
      return Parameters.nearBy.map(values: [latitude, longitude, pageNo, businessId])
    case .nearByFriends(let pageNo):
      return Parameters.nearBy.map(values: [latitude, longitude, pageNo, nil])
    case .sendRequest(let id):
      return Parameters.sendRequest.map(values: [id])
    case .businessDetail(let id):
      return Parameters.businessDetail.map(values: [id])
    case .followUnfollowBusiness(let id, let action):
      return Parameters.followUnfollowBusiness.map(values: [id, action?.rawValue])
    case .followedBusinesses(let pageNo):
      return Parameters.followedBusinesses.map(values: [pageNo])
    case .userFriends(let pageNo, let keyword):
      return Parameters.userFriends.map(values: [pageNo, keyword])
    case .notifications(let pageNo):
      return Parameters.notifications.map(values: [pageNo])
    case .mapDataListing(let radius, let latitude, let longitude, let pageNo, let search, let flag, let nextPageUrl):
      return Parameters.mapDataListing.map(values: [radius, latitude, longitude, pageNo, search, flag.rawValue, nextPageUrl])
    case .homeSearch(let pageNo, let search, let flag):
      return Parameters.homeSearch.map(values: [pageNo, search, flag.rawValue])
    case .contactUs(let message):
      return Parameters.contactUs.map(values: [message])
    case .appDefaults, .getProfile:
      return [:]
    case .objectListing(let objectId, let businessId, let packageId, let pageNo):
      return Parameters.objectListing.map(values: [latitude, longitude, objectId, businessId, packageId, pageNo])
    case .packageListing(let businessId, let packageId, let pageNo):
      return Parameters.packageListing.map(values: [nil, nil, businessId, packageId, pageNo])
    case .getGallery(let businessId, let pageNo):
      return Parameters.getGallery.map(values: [businessId, pageNo])
    case .downloadObject(let objId, let packageId):
      return Parameters.downloadObject.map(values: [objId, packageId, latitude, longitude, UserPreference.shared.data?.currentArea])
    case .acceptRejectRequest(let id, let action):
      return Parameters.acceptRejectRequest.map(values: [id, action.rawValue])
    case .unfriendUser(let userId):
      return Parameters.unfriendUser.map(values: [userId])
    case .uploadItem(let item):
      guard let uploadType = item else { return nil }
      switch uploadType {
      case .image(_):
        return Parameters.uploadImage.map(values: ["CHAT"])
      case .video(_):
        return nil
      }
    case .messageListing(let pageNo):
      return Parameters.messageListing.map(values: [pageNo])
    case .readUnreadNotification(let id, let status):
      return Parameters.readUnreadNotification.map(values: [id, status.rawValue])
    case .nearByBusinessFilters:
      return Parameters.nearByBusinessFilters.map(values: [latitude, longitude])
    }
  }
  
  var parameterEncoding: ParameterEncoding {
    switch self {
    case .nearByBusiness(_),
         .nearByFriends(_),
         .businessDetail(_),
         .userFriends(_),
         .mapDataListing(_),
         .homeSearch(_),
         .appDefaults,
         .objectListing(_),
         .packageListing(_),
         .getGallery(_),
         .getProfile,
         .notifications(_),
         .messageListing(_),
         .nearByBusinessFilters:
      return URLEncoding.queryString
    default:
      return JSONEncoding.default
    }
  }
}

