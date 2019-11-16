//
//  ProfilePicVC.swift
//  AE
//
//  Created by MAC_MINI_6 on 25/03/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

class ProfilePicVC: BaseVC {
  @IBOutlet weak var imgView: UIImageView!
  
  var interMediater: SignupIntermediater?
  
  override func viewDidLoad() {
    super.viewDidLoad()

  }
  
  @IBAction func btnAction(_ sender: UIButton) {
    switch sender.tag {
    case 0: // Back
      popVC()
    case 1: // Select from Gallery
      mediaPicker.pickerType = .LibraryForImage
      mediaPicker.presentPicker({ [weak self] (pickedImage) in
        self?.imgView.image = pickedImage
      })
    case 2: // Open Camera
      mediaPicker.pickerType = .CameraForImage
      mediaPicker.presentPicker({ [weak self] (pickedImage) in
        self?.imgView.image = pickedImage
      })
    case 3: // Finish
      signUpAPIHit()
    default:
      break
    }
    
  }
  
}

//MARK:- VCFuncs
extension ProfilePicVC {
  func signUpAPIHit() {
    if !LocationManager.shared.locationData.isLocationAllowed {
      LocationManager.shared.showSettingAlert()
      return
    }
    
    guard let signUpType = interMediater?.signUpBy else {
      return
    }
    
    EP_Login.userSignUp(name: interMediater?.name, iso: interMediater?.iso, emailOrPhone: interMediater?.emailPhone, facebookId: nil, imageURL: interMediater?.profilePicURL, password: interMediater?.password, signUpBy: signUpType, image: imgView.image).request(success: { [weak self] (response) in
      guard let userModel = (response as? UserData) else {
        return
      }
      
      if signUpType == .EMAIL {
        CommonFuncs.shared.storyboardReInstantiateFor(.Logout)
        Toast.shared.showAlert(type: .success, message: VCLiteral.VERIFICATION_SUCCESS_EMAIL.localized)
        return
      }
      UserPreference.shared.data = userModel
      let destVC = StoryboardScene.GetStarted.VerificationVC.instantiate()
      self?.pushVC(destVC)
    })
  }
}
