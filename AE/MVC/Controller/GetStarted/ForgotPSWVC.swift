//
//  ForgotPSWVC.swift
//  AE
//
//  Created by MAC_MINI_6 on 24/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit
import JVFloatLabeledTextField

class ForgotPSWVC: BaseVC {

  @IBOutlet weak var tfEmailPhone: JVFloatLabeledTextField!
  @IBOutlet weak var btnCC: UIButton!
  
  private var currentCountry: CountryISO?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupInitialValues()
  }
  
  @IBAction func btnAction(_ sender: UIButton) {
    switch sender.tag {
    case 0: // Back
      popVC()
    case 1: // CountryCode
      view.endEditing(true)
      CountryManager.shared.openCountryPicker { [weak self] (country) in
        self?.currentCountry = country
        sender.setTitle("\(country?.Flag ?? "") +\(country?.CC ?? "")", for: .normal)
      }
    case 2: // Done
      let isValid = Validation.shared.validate(values: (.EMAIL_OR_PHONE_FORGOT_PSW, /tfEmailPhone.text?.trimmingCharacters(in: .whitespacesAndNewlines)))
      switch isValid {
      case .success:
        forgotPSWAPI()
      case .failure(let type, let message):
        Toast.shared.showAlert(type: type, message: message.localized)
      }
    default:
      break
    }
  }
  
}

//MARK:- VCFuncs
extension ForgotPSWVC {
  
  private func forgotPSWAPI(){
    
    view.endEditing(true)
    
    let isPhoneNumber = /tfEmailPhone.text?.trimmingCharacters(in: .whitespacesAndNewlines).isNumeric
    let signUpBy: SignupBy = isPhoneNumber ? .PHONE_NUMBER : .EMAIL
    let emailOrPhone = isPhoneNumber ? (/currentCountry?.CC + /tfEmailPhone.text) : /tfEmailPhone.text
  
    
    EP_Login.forgotPassword(emailPhone: emailOrPhone, iso: currentCountry?.ISO, signUpBy: signUpBy).request(success: { [weak self] (response) in
      Toast.shared.showAlert(type: .success, message: String(format: VCLiteral.FORGOT_PSW_SUCCESS.localized, signUpBy.PSWResetBy))
      self?.popVC()
    })
  }
  
  private func setupInitialValues() {
    currentCountry = CountryManager.shared.currentCountry
    btnCC.setTitle("\(currentCountry?.Flag ?? "") +\(currentCountry?.CC ?? "")", for: .normal)
  }
}
