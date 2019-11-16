//
//  SetPasswordVC.swift
//  AE
//
//  Created by MAC_MINI_6 on 25/03/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit
import JVFloatLabeledTextField

class SetPasswordVC: BaseVC {

  @IBOutlet weak var tfPSW: JVFloatLabeledTextField!
  @IBOutlet weak var tfConfirmPSW: JVFloatLabeledTextField!
  
  var interMediater: SignupIntermediater?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tfResponder = TFResponder()
    tfResponder?.addResponders([.TF(tfPSW), .TF(tfConfirmPSW)])
    configureBlocks()
  }
  
  @IBAction func btnAction(_ sender: UIButton) {
    switch sender.tag {
    case 0: //BACK
      popVC()
    case 1: // Password Eye
      sender.setImage(tfPSW.isSecureTextEntry ? #imageLiteral(resourceName: "ic_eye_1") : #imageLiteral(resourceName: "ic_eye_0"), for: .normal)
      tfPSW.isSecureTextEntry.toggle()
    case 2: // Confirm Password Eye
      sender.setImage(tfConfirmPSW.isSecureTextEntry ? #imageLiteral(resourceName: "ic_eye_1") : #imageLiteral(resourceName: "ic_eye_0"), for: .normal)
      tfConfirmPSW.isSecureTextEntry.toggle()
    default: break
    }
  }
  
  override var canBecomeFirstResponder: Bool {
    return true
  }
  
  override var inputAccessoryView: UIView? {
    return accessory
  }
}

//MARK:- VCFuncs
extension SetPasswordVC {
  
  private func configureBlocks() {
    accessory.didTapContinue = { [weak self] in
      let isValid = Validation.shared.validate(values: (.PASSWORD, /self?.tfPSW.text?.trimmingCharacters(in: .whitespacesAndNewlines)), (.CONFIRM_PASSWORD, /self?.tfConfirmPSW.text?.trimmingCharacters(in: .whitespacesAndNewlines)))
      switch isValid {
      case .success:
        if /self?.tfPSW.text?.trimmingCharacters(in: .whitespacesAndNewlines) == /self?.tfConfirmPSW.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
          self?.interMediater?.password = /self?.tfConfirmPSW.text?.trimmingCharacters(in: .whitespacesAndNewlines)
          let destVC = StoryboardScene.GetStarted.ProfilePicVC.instantiate()
          destVC.interMediater = self?.interMediater
          self?.pushVC(destVC)
        } else {
          Toast.shared.showAlert(type: .validationFailure, message: AlertMessage.PASSWORD_NOT_MATCH.localized)
        }
      case .failure(let type, let message):
        Toast.shared.showAlert(type: type, message: message.localized)
      }
    }
  }
  
}
