//
//  VerificationVC.swift
//  AE
//
//  Created by MAC_MINI_6 on 17/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

class VerificationVC: BaseVC {

  @IBOutlet weak var lblOTP_SentTo: UILabel!
  @IBOutlet var tfOTP: [CustomTF]!
    
  override func viewDidLoad() {
    super.viewDidLoad()
    initialSetup()
  }
  
  @IBAction func btnAction(_ sender: UIButton) {
    switch sender.tag {
    case 0: //Back Action
      popVC()
    case 1: //Continue Action
      verificationAPIHit()
    case 2: //Resend OTP
      let phone = UserPreference.shared.data?.phoneNumber
      EP_Login.resendOTP(phoneNumber: "\(/phone?.countryCode)\(/phone?.phoneNo)", iso: phone?.ISO).request(success: { (_) in
        let phone = UserPreference.shared.data?.phoneNumber
        Toast.shared.showAlert(type: .success, message: String(format: VCLiteral.OTP_RESENT_TO.localized, arguments: ["+\(/phone?.countryCode)-\(/phone?.phoneNo)"]))
      })
    default:
      break
    }
  }
}

//MARK:- VCFuncs
extension VerificationVC {
  private func initialSetup() {
    let phone = UserPreference.shared.data?.phoneNumber
    tfOTP.forEach {
      $0.allowedActions = [.toggleBoldface]
    }
    
    lblOTP_SentTo.text = String(format: VCLiteral.OTP_SENT_TO.localized, arguments: ["+\(/phone?.countryCode)-\(/phone?.phoneNo)"])
    
    tfOTP.forEach({ $0.delegate = self })
    
    tfOTP[0].didPressBackWard = { [weak self] in
      self?.textFieldDidDelete()
    }
    
    tfOTP[1].didPressBackWard = { [weak self] in
      self?.textFieldDidDelete()
    }
    
    tfOTP[2].didPressBackWard = { [weak self] in
      self?.textFieldDidDelete()
    }
    
    tfOTP[3].didPressBackWard = { [weak self] in
      self?.textFieldDidDelete()
    }
  }
  
  private func textFieldDidDelete() {
    if tfOTP[1].isFirstResponder{
      tfOTP[0].becomeFirstResponder()
    }
    if tfOTP[2].isFirstResponder{
      tfOTP[1].becomeFirstResponder()
      
    }
    if tfOTP[3].isFirstResponder{
      tfOTP[2].becomeFirstResponder()
    }
  }
  
  private func verificationAPIHit() {
    let otp = /tfOTP[0].text + /tfOTP[1].text + /tfOTP[2].text + /tfOTP[3].text
    if otp == "" {
      Toast.shared.showAlert(type: .validationFailure, message: AlertMessage.EMPTY_OTP.localized)
      return
    }
    let preference = UserPreference.shared.data
    let type = SignupBy(rawValue: /preference?.signUpBy)?.verifyType
    EP_Login.verifyAccount(id: preference?._id, type: type, otp: otp).request(success: { [weak self] (response) in
      let tempValue = UserPreference.shared.data
      tempValue?.isVerified = true
      UserPreference.shared.data = tempValue
      let destVC = StoryboardScene.GetStarted.InviteFriendsVC.instantiate()
      self?.pushVC(destVC)
    })
  }
}

//MARK:- UITextField Delegate and OTP handling
extension VerificationVC: UITextFieldDelegate {
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    var shouldProcess = false //default to reject
    var shouldMoveToNextField = false //default to remaining on the current field
    let  insertStrLength = string.count
    
    if insertStrLength == 0 {
      
      shouldProcess = true //Process if the backspace character was pressed
      
    } else {
      if /textField.text?.count <= 1 {
        shouldProcess = true //Process if there is only 1 character right now
      }
    }
    
    if shouldProcess {
      
      var mString = ""
      if mString.count == 0 {
        
        mString = string
        shouldMoveToNextField = true
        
      } else {
        //adding a char or deleting?
        if(insertStrLength > 0){
          mString = string
          
        } else {
          //delete case - the length of replacement string is zero for a delete
          mString = ""
        }
      }
      
      //set the text now
      textField.text = mString
      if (shouldMoveToNextField && /textField.text?.count == 1) {
        
        if (textField == tfOTP[0]) {
          tfOTP[1].becomeFirstResponder()
          
        } else if (textField == tfOTP[1]){
          tfOTP[2].becomeFirstResponder()
          
        } else if (textField == tfOTP[2]){
          tfOTP[3].becomeFirstResponder()
          
        } else {
          tfOTP[3].resignFirstResponder()
          //API Hit
          verificationAPIHit()
        }
      }
      else{
        self.textFieldDidDelete()
      }
    }
    return false
  }

}

class OTPTextField: UITextField {
  
  var didPressBackWard: (() -> Void)?
  
  override func deleteBackward() {
    super.deleteBackward()
    didPressBackWard?()
  }
}

