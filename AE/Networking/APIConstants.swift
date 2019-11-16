//
//  APIConstants.swift
//  AE
//
//  Created by MAC_MINI_6 on 16/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import Foundation

//Bushra.ba89@gmail.com
//Pass:Bushrabawazir123

enum SDK_KEY: String {
    case GOOGLE_MAPS = "AIzaSyCG2aoy4O4neJulstoFdIiYqXuugJkkYQ0"
}

internal struct APIConstant{
    
//      static let basePath = "http://192.168.102.83:9000" // local vikrant
//    static let basePath = "http://63.34.188.79:9000" //Dev
      static let basePath = "http://63.34.188.79:9001" //Client
  
    
    static let checkUserExist = "/user/v1/checkUserExists"
    static let updateLocation = "/user/v1/updateLocation"
    static let userLogin = "/user/v1/userLogin"
    static let userSignup = "/user/v1/userSignup"
    static let userVerifyAccount = "/user/v1/verifyAccount"
    static let resendOTP = "/user/v1/resendOTP"
    static let changePSW = "/common/v1/changePassword"
    static let editProfile = "/user/v1/editProfile"
    static let forgotPassword = "/user/v1/forgotPassword"
    static let logout = "/user/v1/logout"
    static let syncContacts = "/user/v1/registeredContacts"
    static let nearByBusiness = "/user/v1/nearByBusiness"
    static let nearByFriends = "/user/v1/nearByFriends"
    static let sendRequest = "/user/v1/sendRequest"
    static let businessDetail = "/user/v1/businessDetails"
    static let followUnfollowBusiness = "/user/v1/followUnfollowBusiness"
    static let followedBusinesses = "/user/v1/followedBusiness"
    static let userFriends = "/user/v1/userFriends"
    static let notifications = "/user/v1/notificationListing"
    static let mapDataListing = "/user/v1/mapDataListing"
    static let homeSearch = "/user/v1/homeScreenSearch"
    static let contactUs = "/user/v1/contactUs"
    static let appDefaults = "/user/v1/appDefaults"
    static let objectListing = "/user/v1/objectListing"
    static let packageListing = "/user/v1/packageListing"
    static let getGallery = "/user/v1/getGallery"
    static let getProfile = "/user/v1/getProfile"
    static let downloadObject = "/user/v1/downloadObject"
    static let acceptRejectRequest = "/user/v1/acceptRejectRequest"
    static let unfriendUser = "/user/v1/unfriendUser"
    static let messageListing = "/user/v1/messageListing"
    static let readUnreadNotification = "/user/v1/readUnreadClearNotification"
    static let nearByBusinessFilters = "/user/v1/nearByBusinessFilters"
    
    static let uploadImage = "/common/v1/uploadImage"
    static let uploadVideo = "/common/v1/uploadVideo"
}

typealias OptionalDictionary = [String : Any]?

extension Sequence where Iterator.Element == Keys {
    func map(values: [String?]) -> OptionalDictionary {
        var params = [String : Any]()
        
        for (index,element) in zip(self,values) {
            if /element != "" {
                params[index.rawValue] = element
            }
        }
        return params
    }
}

enum Keys: String {
    
    typealias RawValue = String
    
    case emailOrPhoneNumber = "emailOrPhoneNumber"
    case ISO = "ISO"
    case signUpBy = "signUpBy"
    case lat = "lat"
    case long = "long"
    case locality = "locality"
    case password = "password"
    case name = "name"
    case facebookId = "facebookId"
    case imageUrl = "imageUrl"
    case id = "id"
    case type = "type"
    case OTPcode = "OTPcode"
    case oldPassword = "oldPassword"
    case newPassword = "newPassword"
    case email = "email"
    case phoneNumber = "phoneNumber"
    case pageNo = "pageNo"
    case receiverId = "receiverId"
    case showLocation = "showLocation"
    case imageUrl_FB = "imageUrl_FB"
    case action = "action"
    case userId = "userId"
    case deviceToken = "deviceToken"
    case deviceId = "deviceId"
    case radius = "radius"
    case search = "search"
    case flag = "flag"
    case nextPageUrl = "nextPageUrl"
    case message = "message"
    case objectId = "objectId"
    case packageId = "packageId"
    case businessId = "businessId"
    case notificationId = "notificationId"
    case status = "status"
}

struct Parameters {
    static let checkUserExist: [Keys] = [.emailOrPhoneNumber, .ISO, .signUpBy]
    static let updateLocation: [Keys] = [.lat, .long, .showLocation] //with authorization
    static let userLogin: [Keys] = [.emailOrPhoneNumber, .ISO, .password, .signUpBy, .lat, .long, .deviceToken]
    static let userSignUp: [Keys] = [.name, .ISO, .emailOrPhoneNumber, .facebookId, .imageUrl_FB, .password, .signUpBy, .lat, .long, .deviceToken]
    static let userVerifyAccount: [Keys] = [.id, .type, .OTPcode]
    static let resendOTP: [Keys] = [.emailOrPhoneNumber, .ISO]
    static let changePSW: [Keys] = [.oldPassword, .newPassword]
    static let editProfile: [Keys] = [.name, .email, .phoneNumber, .ISO]
    static let forgotPassword: [Keys] = [.emailOrPhoneNumber, .ISO, .signUpBy]
    static let syncContacts: [Keys] = [.phoneNumber]
    static let nearBy: [Keys] = [.lat, .long, .pageNo, .businessId]
    static let sendRequest: [Keys] = [.receiverId]
    static let businessDetail: [Keys] = [.id]
    static let followUnfollowBusiness: [Keys] = [.id, .action]
    static let followedBusinesses: [Keys] = [.pageNo]
    static let userFriends: [Keys] = [.pageNo, .search]
    static let notifications: [Keys] = [.pageNo]
    static let mapDataListing: [Keys] = [.radius, .lat, .long, .pageNo, .search, .flag, .nextPageUrl]
    static let homeSearch: [Keys] = [.pageNo, .search, .flag]
    static let contactUs: [Keys] = [.message]
    static let objectListing: [Keys] = [.lat, .long, .objectId, .businessId, .packageId, .pageNo]
    static let packageListing: [Keys] = [.lat, .long, .businessId, .packageId, .pageNo]
    static let getGallery: [Keys] = [.businessId, .pageNo]
    static let downloadObject: [Keys] = [.objectId, .packageId, .lat, .long, .locality]
    static let acceptRejectRequest: [Keys] = [.id, .action]
    static let unfriendUser: [Keys] = [.userId]
    static let uploadImage: [Keys] = [.type]
    static let messageListing: [Keys] = [.pageNo]
    static let readUnreadNotification: [Keys] = [.notificationId, .status]
    static let nearByBusinessFilters: [Keys] = [.lat, .long]
}
