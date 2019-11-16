//
//  SignUpVC.swift
//  AE
//
//  Created by MAC_MINI_6 on 19/03/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit
import JVFloatLabeledTextField

class SignUpVC: BaseVC {
  
  @IBOutlet weak var btnCC: UIButton!
  @IBOutlet weak var lblLogin: UILabel!
  @IBOutlet weak var tfEmailPhone: JVFloatLabeledTextField!
  @IBOutlet weak var tfName: JVFloatLabeledTextField!
  @IBOutlet weak var btnContinue: UIButton!
  
  private var currentCountry: CountryISO?
  private var interMediater: SignupIntermediater?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureBlocks()
    setupInitialValues()
  }
  
  override var canBecomeFirstResponder: Bool {
    return false
  }
  
  override var inputAccessoryView: UIView? {
    return accessory
  }
  
  //MARK:- IBActions
  @IBAction func btnAction(_ sender: UIButton) {
    switch sender.tag {
    case 0: //Back
      popVC()
    case 1: //Facebook
      FBLogin.shared.login { [weak self] (response) in
        self?.fbSignUpAPI(response)
      }
    case 2: //CountryCode
      tfEmailPhone.resignFirstResponder()
      CountryManager.shared.openCountryPicker { [weak self] (country) in
        self?.currentCountry = country
        sender.setTitle("\(country?.Flag ?? "") +\(country?.CC ?? "")", for: .normal)
      }
    case 3: //Continue
      view.endEditing(true)
      validateInput()
    default: break
    }
  }
  
}

//MARK:- VCFuncs
extension SignUpVC {
  private func fbSignUpAPI(_ response: GoogleFBUserData?) {
    
    let dictImage = JSONHelper<ImageURL>().toJSONString(model: ImageURL(response?.imageURL?.absoluteString))
    
    EP_Login.userSignUp(name: response?.name, iso: nil, emailOrPhone: response?.email, facebookId: response?.id, imageURL: dictImage, password: nil, signUpBy: SignupBy.FACEBOOK, image: nil).request(success: { [weak self] (response) in
      guard let userModel = (response as? UserData) else {
        return
      }
      UserPreference.shared.data = userModel
      if /userModel.isLoginFromFB {
        CommonFuncs.shared.storyboardReInstantiateFor(.SuccessLogin)
      } else {
        let destVC = StoryboardScene.GetStarted.InviteFriendsVC.instantiate()
        self?.pushVC(destVC)
      }
    }) { (error) in
      
    }
  }
  
  private func setupInitialValues() {
    tfResponder = TFResponder()
    tfResponder?.addResponders([.TF(tfName), .TF(tfEmailPhone)])
    tfResponder?.isFieldResigned = { [weak self] (isResigned) in
      self?.accessory.btn.isHidden = isResigned
      self?.btnContinue.isHidden = !isResigned
    }
    currentCountry = CountryManager.shared.currentCountry
    btnCC.setTitle("\(currentCountry?.Flag ?? "") +\(currentCountry?.CC ?? "")", for: .normal)
  }
  
  private func configureBlocks() {
    accessory.didTapContinue = { [weak self] in
     self?.validateInput()
    }
    
    lblLogin.addTapGestureRecognizer { [weak self] in
      let destVC = StoryboardScene.GetStarted.LoginVC.instantiate()
      self?.pushVC(destVC)
    }
  }
  
  private func validateInput() {
    let isValid = Validation.shared.validate(values: (.NAME, /tfName.text?.trimmingCharacters(in: .whitespacesAndNewlines)), (.EMAIL_OR_PHONE, /tfEmailPhone.text?.trimmingCharacters(in: .whitespacesAndNewlines)))
    switch isValid {
    case .success:
      checkAccountExistedOrNot()
    case .failure(let type, let message):
      Toast.shared.showAlert(type: type, message: message.localized)
    }
  }
  
  private func checkAccountExistedOrNot() {
    
    let isPhoneNumber = /tfEmailPhone.text?.trimmingCharacters(in: .whitespacesAndNewlines).isNumeric
    let signUpBy: SignupBy = isPhoneNumber ? .PHONE_NUMBER : .EMAIL
    let emailOrPhone = isPhoneNumber ? (/currentCountry?.CC + /tfEmailPhone.text) : /tfEmailPhone.text
    
    interMediater = SignupIntermediater(tfName.text?.trimmingCharacters(in: .whitespacesAndNewlines), tfEmailPhone.text?.trimmingCharacters(in: .whitespacesAndNewlines), currentCountry?.ISO)
    
    view.endEditing(true)
    
    EP_Login.checkUserExist(emailOrPhone: emailOrPhone.trimmingCharacters(in: .whitespacesAndNewlines), iso: currentCountry?.ISO, signUpBy: signUpBy).request(success: { [weak self] (response) in
      
      let destVC = StoryboardScene.GetStarted.SetPasswordVC.instantiate()
      destVC.interMediater = self?.interMediater
      self?.pushVC(destVC)
    })
  }
}
