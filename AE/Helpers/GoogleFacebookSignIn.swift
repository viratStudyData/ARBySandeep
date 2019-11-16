//
//  GoogleFacebookSignIn.swift
//  BlockChain-Game
//
//  Created by MAC_MINI_6 on 05/12/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
//import GoogleSignIn
import FBSDKLoginKit

//-------------------------------------------------------------------------------------------------------------------
//MARK:- GoogleSigin Class
//class GoogleSignIn: NSObject, GIDSignInDelegate, GIDSignInUIDelegate {
//
//  typealias SuccessCallBack = ((_ userData: GoogleFBUserData?) -> ())
//  var successCallBack: SuccessCallBack?
//
//  static let shared = GoogleSignIn()
//
//  override init() {
//    super.init()
//    GIDSignIn.sharedInstance()?.clientID = /CommonFuncs.shared.infoForKey("GOOGLE_CLIENT_ID")
//    GIDSignIn.sharedInstance().delegate = self
//    GIDSignIn.sharedInstance()?.uiDelegate = self
//  }
//
//  func openGoogleSigin(success: SuccessCallBack?) {
//    GIDSignIn.sharedInstance()?.signOut()
//    GIDSignIn.sharedInstance().signIn()
//    successCallBack = success
//  }
//
//  //MARK:- GIDSignInDelegate Method
//  func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
//    if error == nil {
//      successCallBack?(GoogleFBUserData.init(user.profile.name, user.userID, user.profile.email, user.profile.imageURL(withDimension: 120)))
//    }
//  }
//
//  //MARK:- Below Methods are of GIDSignInUIDelegate implement only if your class is not a subclass of UIViewController
//
//  // Stop the UIActivityIndicatorView animation that was started when the user
//  // pressed the Sign In button
//  func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
//
//  }
//
//  // Present a view that prompts the user to sign in with Google
//  func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
//    viewController.navigationController?.navigationBar.tintColor = UIColor.black
//    UIApplication.topVC()?.present(viewController, animated: true, completion: nil)
//  }
//
//  // Dismiss the "Sign in with Google" view
//  func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
//    viewController.dismiss(animated: true, completion: nil)
//  }
//
//}

//-------------------------------------------------------------------------------------------------------------------
//MARK:- Facebook Login Class
class FBLogin: NSObject {
  
  static let shared = FBLogin()
  
  typealias SuccessCallBack = ((_ userData: GoogleFBUserData?) -> ())
  var successCallBack: SuccessCallBack?
  
  func login(_ success: SuccessCallBack?) {
    successCallBack = success
    AccessToken.current = nil
    Profile.current = nil
    LoginManager().logOut()
    LoginManager().logIn(permissions: ["email", "public_profile", "user_friends"], from: UIApplication.topVC()) { (result, err) in
      if err != nil {
        print("failed to start graph request: \(String(describing: err))")
        return
      }
      self.getEmailNameIdImageFromFB()
    }
  }
  
  fileprivate func getEmailNameIdImageFromFB() {
    GraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email, picture.width(480).height(480)"]).start { [weak self] (connection, result, err) -> Void in
      if err != nil {
        print("failed to start graph request: \(String(describing: err))")
        return
      }
      print(result ?? "")
      let fbData = GoogleFBUserData(result: result as AnyObject?)
      self?.successCallBack?(fbData)
    }
  }
}

//MARK:- Google and Facebook Model
//-------------------------------------------------------------------------------------------------------------------
class GoogleFBUserData {
  var name: String?
  var id: String?
  var email: String?
  var imageURL: URL?
  var isThroughGoogle = false
  
  init(_ _name: String?, _ _id: String?, _ _email: String?, _ _imageURL: URL?) {
    name = _name
    id = _id
    email = _email
    imageURL = _imageURL
    isThroughGoogle = true
  }
  
  init(result : AnyObject?) {
    guard let fbResult = result else { return }
    id = fbResult.value(forKey: "id") as? String
    name = fbResult.value(forKey: "name") as? String
    email = fbResult.value(forKey: "email") as? String
    imageURL = URL.init(string: "https://graph.facebook.com/".appending(/AccessToken.current?.userID).appending("/picture?type=large"))
    isThroughGoogle = false
  }
}
//-------------------------------------------------------------------------------------------------------------------
