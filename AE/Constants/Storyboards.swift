//
//  Storyboards.swift
//  AE
//
//  Created by MAC_MINI_6 on 19/03/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

protocol StoryboardType {
  static var storyboardName: String { get }
}

extension StoryboardType {
  static var storyboard: UIStoryboard {
    let name = self.storyboardName
    return UIStoryboard(name: name, bundle: Bundle(for: BundleToken.self))
  }
}

struct SceneType<T: Any> {
  let storyboard: StoryboardType.Type
  let identifier: String
  
  func instantiate() -> T {
    let identifier = self.identifier
    guard let controller = storyboard.storyboard.instantiateViewController(withIdentifier: identifier) as? T else {
      fatalError("ViewController '\(identifier)' is not of the expected class \(T.self).")
    }
    return controller
  }
}


struct InitialSceneType<T: Any> {
  let storyboard: StoryboardType.Type
  
  func instantiate() -> T {
    guard let controller = storyboard.storyboard.instantiateInitialViewController() as? T else {
      fatalError("ViewController is not of the expected class \(T.self).")
    }
    return controller
  }
}

protocol SegueType: RawRepresentable { }

extension UIViewController {
  func perform<S: SegueType>(segue: S, sender: Any? = nil) where S.RawValue == String {
    let identifier = segue.rawValue
    performSegue(withIdentifier: identifier, sender: sender)
  }
}

// swiftlint:disable explicit_type_interface identifier_name line_length type_body_length type_name
enum StoryboardScene {
  
  enum GetStarted: StoryboardType {
    static let storyboardName = "GetStarted"
    
    static let initialScene = InitialSceneType<UINavigationController>(storyboard: GetStarted.self)
    
    static let LandingVC = SceneType<AE.LandingVC>(storyboard: GetStarted.self, identifier: "LandingVC")
   
    static let SignUpVC = SceneType<AE.SignUpVC>(storyboard: GetStarted.self, identifier: "SignUpVC")
    
    static let LoginVC = SceneType<AE.LoginVC>(storyboard: GetStarted.self, identifier: "LoginVC")
    
    static let SetPasswordVC = SceneType<AE.SetPasswordVC>(storyboard: GetStarted.self, identifier: "SetPasswordVC")
    
    static let ProfilePicVC = SceneType<AE.ProfilePicVC>(storyboard: GetStarted.self, identifier: "ProfilePicVC")
    
    static let InviteFriendsVC = SceneType<AE.InviteFriendsVC>(storyboard: GetStarted.self, identifier: "InviteFriendsVC")
    
    static let ContactsFacebookVC = SceneType<AE.ContactsFacebookVC>(storyboard: GetStarted.self, identifier: "ContactsFacebookVC")
    
    static let VerificationVC = SceneType<AE.VerificationVC>(storyboard: GetStarted.self, identifier: "VerificationVC")
    
    static let ChangePSWVC = SceneType<AE.ChangePSWVC>(storyboard: GetStarted.self, identifier: "ChangePSWVC")
    
    static let ForgotPSWVC = SceneType<AE.ForgotPSWVC>(storyboard: GetStarted.self, identifier: "ForgotPSWVC")
  }
  
  enum TabSB: StoryboardType {
    
    static let storyboardName = "TabSB"
    
    static let initialScene = InitialSceneType<TabVC>(storyboard: TabSB.self)
  }
  
  enum Other: StoryboardType {
    
    static let storyboardName = "Other"
    
    static let ListingVC = SceneType<AE.ListingVC>(storyboard: Other.self, identifier: "ListingVC")
    
    static let PackagesTabVC = SceneType<AE.PackagesTabVC>(storyboard: Other.self, identifier: "PackagesTabVC")
    
    static let ObjectsTabVC = SceneType<AE.ObjectsTabVC>(storyboard: Other.self, identifier: "ObjectsTabVC")
    
    static let ProfileVC = SceneType<AE.ProfileVC>(storyboard: Other.self, identifier: "ProfileVC")
    
    static let BusinessDetailVC = SceneType<AE.BusinessDetailVC>(storyboard: Other.self, identifier: "BusinessDetailVC")
    
    static let SettingsVC = SceneType<AE.SettingsVC>(storyboard: Other.self, identifier: "SettingsVC")
    
    static let EditProfileVC = SceneType<AE.EditProfileVC>(storyboard: Other.self, identifier: "EditProfileVC")
    
    static let FollowingVC = SceneType<AE.FollowingVC>(storyboard: Other.self, identifier: "FollowingVC")
    
    static let FriendsVC = SceneType<AE.FriendsVC>(storyboard: Other.self, identifier: "FriendsVC")
    
    static let MessagesVC = SceneType<AE.MessagesVC>(storyboard: Other.self, identifier: "MessagesVC")
    
    static let SearchVC = SceneType<AE.SearchVC>(storyboard: Other.self, identifier: "SearchVC")
    
    static let ContactUsVC = SceneType<AE.ContactUsVC>(storyboard: Other.self, identifier: "ContactUsVC")
    
    static let AboutUsVC = SceneType<AE.AboutUsVC>(storyboard: Other.self, identifier: "AboutUsVC")
    
    static let GalleryVC = SceneType<AE.GalleryVC>(storyboard: Other.self, identifier: "GalleryVC")
    
    static let PackageDetailVC = SceneType<AE.PackageDetailVC>(storyboard: Other.self, identifier: "PackageDetailVC")
    
    static let ARNavigationVC = SceneType<AE.ARNavigationVC>(storyboard: Other.self, identifier: "ARNavigationVC")
    
    static let ObjPreviewVC = SceneType<AE.ObjPreviewVC>(storyboard: Other.self, identifier: "ObjPreviewVC")
    
    static let CameraVC = SceneType<AE.CameraVC>(storyboard: Other.self, identifier: "CameraVC")
    
    static let ShareVideoImgVC = SceneType<AE.ShareVideoImgVC>(storyboard: Other.self, identifier: "ShareVideoImgVC")
    
    static let ShareWithVC = SceneType<AE.ShareWithVC>(storyboard: Other.self, identifier: "ShareWithVC")
    
    static let MediaPreviewVC = SceneType<AE.MediaPreviewVC>(storyboard: Other.self, identifier: "MediaPreviewVC")
    
    static let Video360VC = SceneType<AE.Video360VC>(storyboard: Other.self, identifier: "Video360VC")
    
    static let FrontCamVC = SceneType<AE.FrontCamVC>(storyboard: Other.self, identifier: "FrontCamVC")
    
    static let Image360VC = SceneType<AE.Image360VC>(storyboard: Other.self, identifier: "Image360VC")
  }
  
  enum PopUp: StoryboardType {
    
    static let storyboardName = "PopUp"

    static let LoginPopUpVC = SceneType<AE.LoginPopUpVC>(storyboard: PopUp.self, identifier: "LoginPopUpVC")
    
    static let UnfollowPopUpVC = SceneType<AE.UnfollowPopUpVC>(storyboard: PopUp.self, identifier: "UnfollowPopUpVC")

    
  }
}



enum StoryboardSegue {
  
}
// swiftlint:enable explicit_type_interface identifier_name line_length type_body_length type_name

private final class BundleToken {}
