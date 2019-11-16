//
//  LoginVC.swift
//  AE
//
//  Created by MAC_MINI_6 on 25/03/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit
import JVFloatLabeledTextField

class LoginVC: BaseVC {

  @IBOutlet weak var tfEmailPhone: JVFloatLabeledTextField!
  @IBOutlet weak var tfPassword: JVFloatLabeledTextField!
  @IBOutlet weak var btnCC: UIButton!
  @IBOutlet weak var lblSignUp: UILabel!
  
  private var currentCountry: CountryISO?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupInitalValues()
    configureBlocks()
  }

  override var canBecomeFirstResponder: Bool {
    return true
  }
  
  override var inputAccessoryView: UIView? {
    return accessory
  }
  
  @IBAction func btnAction(_ sender: UIButton) {
    switch sender.tag {
    case 0: //Back
      popVC()
    case 1: //Country Code
      CountryManager.shared.openCountryPicker { [weak self] (country) in
        self?.currentCountry = country
        sender.setTitle("\(self?.currentCountry?.Flag ?? "") +\(self?.currentCountry?.CC ?? "")", for: .normal)
      }
    case 2: //Forgot Password
      let destVC = StoryboardScene.GetStarted.ForgotPSWVC.instantiate()
      pushVC(destVC)
    default:
      break
    }
  }
  
}

//MARK:- VCFuncs
extension LoginVC {
  
  private func setupInitalValues() {
    tfResponder = TFResponder()
    tfResponder?.addResponders([.TF(tfEmailPhone), .TF(tfPassword)])
    currentCountry = CountryManager.shared.currentCountry
    btnCC.setTitle("\(currentCountry?.Flag ?? "") +\(currentCountry?.CC ?? "")", for: .normal)
  }
  
  private func configureBlocks() {
    
    accessory.setTitle(.LOGIN)
    
    accessory.didTapContinue = { [weak self] in
      let isValid = Validation.shared.validate(values: (.EMAIL_OR_PHONE, /self?.tfEmailPhone.text), (.LOGIN_PSW, /self?.tfPassword.text))
      switch isValid {
      case .success:
        self?.view.endEditing(true)
        self?.loginAPIHit()
      case .failure(let type, let message):
        Toast.shared.showAlert(type: type, message: message.localized)
      }
    }
    
    lblSignUp.addTapGestureRecognizer { [weak self] in
      self?.popVC()
    }
    
  }
  
  private func loginAPIHit() {
    let isPhoneNumber = /tfEmailPhone.text?.isNumeric
    let signUpBy: SignupBy = isPhoneNumber ? .PHONE_NUMBER : .EMAIL
    let emailOrPhone = isPhoneNumber ? (/currentCountry?.CC + /tfEmailPhone.text) : /tfEmailPhone.text
    
    if !LocationManager.shared.locationData.isLocationAllowed {
      LocationManager.shared.showSettingAlert()
      return
    }
    
    EP_Login.userLogin(emailOrPhone: emailOrPhone, iso: currentCountry?.ISO, password: tfPassword.text, signUpBy: signUpBy).request(success: { [weak self] (response) in
      UserPreference.shared.data = (response as? UserData)
      
      let signUpType = SignupBy(rawValue: /UserPreference.shared.data?.signUpBy) ?? .EMAIL
      switch signUpType {
      case .PHONE_NUMBER, .FACEBOOK:
        if /UserPreference.shared.data?.isVerified {
          CommonFuncs.shared.storyboardReInstantiateFor(.SuccessLogin)
        } else {
          let destVC = StoryboardScene.GetStarted.VerificationVC.instantiate()
          self?.pushVC(destVC)
        }
      case .EMAIL:
        CommonFuncs.shared.storyboardReInstantiateFor(.SuccessLogin)
      }
    })
  }
  
}
