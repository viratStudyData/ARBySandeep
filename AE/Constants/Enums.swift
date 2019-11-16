//
//  Enums.swift
//  AE
//
//  Created by MAC_MINI_6 on 04/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

enum MediaType_AE: String, Codable {
  case IMAGE = "IMAGE"
  case VIDEO360 = "360VIDEO"
  case VIDEO = "VIDEO"
  case IMAGE360 = "360IMAGE"
  case OBJECT = "3DOBJECT"
}

enum RequestAction: String {
  case ACCEPT = "ACCEPT"
  case REJECT = "REJECT"
}

enum DownloadStatus: Int, Codable {
  case NONE = 0
  case DOWNLOADING = 1
  case DOWNLOADED = 2
  case PENDING = 3
  case PAUSED = 4
  case FAILED = 5
  case RESUMED = 6
}

enum MapFlag: String {
  case ALL = "ALL"
  case BUSINESS = "BUSINESS"
  case GLOBAL = "GLOBAL"
  case USER = "USER"
}

enum BtnMapFlag: Int {
  case Friends = 0 //Friends
  case Businesses = 1 //Businesses
  case Global = 2 //Global
  
  var flag: MapFlag {
    switch self {
    case .Friends:
      return MapFlag.USER
    case .Businesses:
      return MapFlag.BUSINESS
    case .Global:
      return MapFlag.GLOBAL
    }
  }
  
  func uiProperty(isSelected: Bool) -> (backColor: UIColor, textColor: UIColor) {
    return isSelected ? (Color.buttonBlue.value, Color.textWhite.value) : (Color.backgroundWhite.value, Color.textBlue.value)
  }
}

enum NotificationType: String, Codable {
  case FRIEND_REQUEST = "FRIEND_REQUEST"
  case REQUEST_ACCEPTED = "REQUEST_ACCEPTED"
  case NEAR_BY_BUSINESS = "NEAR_BY_BUSINESS"
  case NEAR_BY_OBJECT = "NEAR_BY_OBJECT"
  case UPLOADED_PACKAGE = "UPLOADED_PACKAGE"
  case UPLOADED_OBJECT = "UPLOADED_OBJECT"
  case SENT_MESSAGE = "SENT_MESSAGE"
  case ADMIN_NOTIFICATION = "ADMIN_NOTIFICATION"
}

enum InviteNavigation {
  case FromSignUp
  case FromProfile
  
  var isSkipHidden: Bool {
    switch self {
    case .FromSignUp:
      return false
    case .FromProfile:
      return true
    }
  }
  
  var isBackHidden: Bool {
    return !isSkipHidden
  }
}

enum InviteFriendsLoad {
  case GettingContacts
  case SyncingContacts
  case NoContacts
  case ContactsDenied
  case CustomError(error: String)
  case DataLoaded
  
  case GettingFBcontacts
  case SyncingFBcontacts
  case NoFBfriends
  case NoFBSignup
  
  var showLoader: Bool {
    switch self {
    case .NoContacts, .ContactsDenied, .CustomError(_), .DataLoaded, .NoFBSignup, .NoFBfriends:
      return false
    default:
      return true
    }
  }
  
  var showButton: Bool {
    switch self {
    case .ContactsDenied, .CustomError(_):
      return false
    default:
      return true
    }
  }
  
  var showMessage: Bool {
    switch self {
    case .DataLoaded:
      return true
    default:
      return false
    }
  }
  
  var btnTitle: String? {
    switch self {
    case .ContactsDenied:
      return VCLiteral.SETTINGS.localized
    case .CustomError(_):
      return VCLiteral.RETRY.localized
    default:
      return nil
    }
  }
  
  var message: String? {
    switch self {
    case .GettingContacts:
      return VCLiteral.GETTING_CONTACTS.localized
    case .SyncingContacts:
      return VCLiteral.SYNCING_CONTACTS.localized
    case .NoContacts:
      return VCLiteral.NO_CONTACTS.localized
    case .ContactsDenied:
      return VCLiteral.CONTACTS_DENIED.localized
    case .CustomError(let error):
      return error
    case .DataLoaded:
      return nil
    case .GettingFBcontacts:
      return VCLiteral.GETTING_FB_CONTACTS.localized
    case .SyncingFBcontacts:
      return VCLiteral.SYNC_FB_CONTACTS.localized
    case .NoFBfriends:
      return VCLiteral.NO_FB_FRIENDS.localized
    case .NoFBSignup:
      return VCLiteral.NO_FB_SIGNUP.localized
    }
  }
  
}

enum HorizontalCollectionLoad {
  case LoadingExperiencesFromAPI
  case GettingLocation
  case LocationDisabled
  case LoadingFriendsFromAPI
  case NoNearByExperiences
  case NoNearByFriends
  case NoFriendsGuestLogin
  case DataLoaded
  case CustomError(error: String)
  
  var showMainView: Bool {
    switch self {
    case .DataLoaded:
      return true
    default:
      return false
    }
  }
  
  var showLoader: Bool {
    switch self {
    case .LoadingExperiencesFromAPI, .GettingLocation, .LoadingFriendsFromAPI:
      return true
    case .LocationDisabled, .NoNearByFriends, .NoNearByExperiences, .NoFriendsGuestLogin, .DataLoaded, .CustomError(_):
      return false
    }
  }
  
  var showButton: Bool {
    switch self {
    case .GettingLocation, .LoadingExperiencesFromAPI, .LoadingFriendsFromAPI, .NoNearByExperiences, .NoNearByFriends, .DataLoaded:
      return false
    case .LocationDisabled, .NoFriendsGuestLogin, .CustomError(_):
      return true
    }
  }
  
  var btnTitle: VCLiteral? {
    switch self {
    case .LocationDisabled:
      return .SETTINGS
    case .NoFriendsGuestLogin:
      return .SIGNUP
    case .CustomError(_):
      return .RETRY
    default:
      return nil
    }
  }
  
  var message: String? {
    switch self {
    case .GettingLocation:
      return VCLiteral.GETTING_LOCATION.localized
    case .LoadingExperiencesFromAPI:
      return VCLiteral.GETTING_NEARBY_EXPERIENCES.localized
    case .LocationDisabled:
      return VCLiteral.ALLOW_LOCATION.localized
    case .LoadingFriendsFromAPI:
      return VCLiteral.GETTING_FRIENDS.localized
    case .NoNearByExperiences:
      return VCLiteral.NO_NEARBY_EXPEREINCES.localized
    case .NoNearByFriends:
      return VCLiteral.NO_NEARBY_FRIENDS.localized
    case .NoFriendsGuestLogin:
      return VCLiteral.NO_FRIENDS_GUEST_LOGIN.localized
    case .DataLoaded:
      return nil
    case .CustomError(let error):
      return error
    }
  }
}


enum SignupBy: String {
  case EMAIL = "EMAIL"
  case FACEBOOK = "FACEBOOK"
  case PHONE_NUMBER = "PHONE_NUMBER"
  
  var verifyType: String {
    switch self {
    case .EMAIL:
      return "1"
    case .PHONE_NUMBER:
      return "2"
    case .FACEBOOK:
      return "0"
    }
  }
  
  var PSWResetBy: String {
    switch self {
    case .EMAIL:
      return VCLiteral.EMAIL.localized
    case .PHONE_NUMBER:
      return VCLiteral.PHONE.localized
    case .FACEBOOK:
      return ""
    }
  }
}

enum InviteFriendTab: Int {
  case Contacts = 0
  case Facebook = 1
  
  var title: String {
    switch self {
    case .Contacts:
      return VCLiteral.INVITE_FRIEND_TAB_1.localized
    case .Facebook:
      return VCLiteral.INVITE_FRIEND_TAB_2.localized
    }
  }
  
  var placeHolderTitle: String {
    switch self {
    case .Contacts:
      return VCLiteral.NO_CONTACTS.localized
    case .Facebook:
      return VCLiteral.NO_FB_FRIENDS.localized
    }
  }
}

enum DownloadsTab: Int {
  case Package = 0
  case Objects = 1
  
  var title: String {
    switch self {
    case .Package:
      return VCLiteral.PACKAGES_TAB_TITLE.localized
    case .Objects:
      return VCLiteral.OBJECTS_TAB_TITLE.localized
    }
  }
}

enum ReInstantiatePurpose: Int {
  case SuccessLogin
  case SuccessSignUp
  case Logout
  case LanguageChangeGetStarted
  case LanguageChangeTabSB
  case SessionExpired
  case GuestLogin
  
  var vcLinked: UIViewController {
    switch self {
    case .SuccessLogin, .SuccessSignUp, .GuestLogin, .LanguageChangeTabSB:
      return StoryboardScene.TabSB.initialScene.instantiate()
    case .Logout, .LanguageChangeGetStarted, .SessionExpired:
      return StoryboardScene.GetStarted.initialScene.instantiate()
    }
  }
}

enum AccessoryTitle {
  case LOGIN
  case CONTINUE
  
  var title: String {
    switch self {
    case .LOGIN:
      return VCLiteral.LOGIN_TITLE.localized
    case .CONTINUE:
      return VCLiteral.CONTINUE_TITLE.localized
    }
  }
}

enum ListingType {
  
  typealias Property = (title: String, subtitle: String, identifier: String, cellHeight: CGFloat, separatorStyle: UITableViewCell.SeparatorStyle)
  
  case NearbyBusiness
  case NearbyFriends
  case BusinessDetailPackages(by: Business?)
  case BusinessDetailObjects(by: Business?)
  case BusinessBranches(of: Business?)
  
  var property: Property {
    switch self {
    case .NearbyBusiness:
      return (VCLiteral.NEARBY_EXPERIENCES.localized, "", BusinessListingCell.identfier, UITableView.automaticDimension, .none)
    case .NearbyFriends:
      return (VCLiteral.NEARBY_FRIENDS.localized, "", FriendListingCell.identfier, UITableView.automaticDimension, .none)
    case .BusinessDetailPackages(let business):
       return (VCLiteral.BUSINESS_DETAIL_PACKAGE_TITLE.localized, String(format: VCLiteral.AR_PACKAGE_BY.localized, arguments: [/business?.name]), PackageCell.identfier, TableHeight.PackageCell, .none)
    case .BusinessDetailObjects(let business):
      return (VCLiteral.BUSINESS_DETAIL_OBJECTS_TITLE.localized, String(format: VCLiteral.AR_PACKAGE_BY.localized, arguments: [/business?.name]), ThreeD_ObjectCell.identfier, TableHeight.DownloadedObject, .singleLine)
    case .BusinessBranches(_):
      return (VCLiteral.ALL_BRANCHES.localized, "", BranchListingCell.identfier, TableHeight.BranchListingCell, .singleLine)
    }
  }
}

enum InviteStatus: String {
  case INVITE = "INVITE"
  case ADD_FRIEND = "ADD"
  case REJECTED = "REJECTED"
  case REQUESTED = "REQUESTED"
  case ACCEPTED = "ACCEPTED"
  case UNFRIEND = "UNFRIEND"
  
  var title: String {
    switch self {
    case .INVITE:
      return VCLiteral.INVITE.localized
    case .ADD_FRIEND, .REJECTED, .UNFRIEND:
      return VCLiteral.ADD_FRIEND.localized
    case .REQUESTED:
      return VCLiteral.REQUESTED.localized
    case .ACCEPTED:
      return VCLiteral.UNFRIEND.localized
    }
  }
  
  var btnWidth: CGFloat {
    return title.widthOfString(usingFont: Fonts.SFProTextMedium.ofSize(12)) + 24
  }
}

enum FollowAction: String {
  case FOLLOW = "FOLLOW"
  case UNFOLLOW = "UNFOLLOW"
}

extension Bool {
  var actionToAPI: FollowAction {
    return self ? .UNFOLLOW : .FOLLOW
  }
  
  var followUnfollowBtnType: FollowUnfollow {
    return self ? .Unfollow : .Follow
  }
}

enum FollowUnfollow {
  case Follow
  case Unfollow
  
  var title: VCLiteral {
    switch self {
    case .Follow:
      return .FOLLOW
    case .Unfollow:
      return .UNFOLLOW
    }
  }
  
  var textColor: UIColor {
    switch self {
    case .Follow:
      return Color.textWhite.value
    case .Unfollow:
      return Color.text282828_90.value
    }
  }
  
  var btnColor: UIColor {
    switch self {
    case .Follow:
      return Color.buttonBlue.value
    case .Unfollow:
      return Color.backgroundWhite.value
    }
  }
  
  var btnWidth: CGFloat {
    return title.localized.widthOfString(usingFont: Fonts.SFProTextMedium.ofSize(12)) + 32
  }
  
  var borderColor: UIColor {
    switch self {
    case .Follow:
      return Color.buttonBlue.value
    case .Unfollow:
      return Color.text282828_90.value
    }
  }
  
  var borderWidth: CGFloat {
    switch self {
    case .Follow:
      return 0
    case .Unfollow:
      return 1
    }
  }
}
