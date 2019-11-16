//
//  ChangePSWVC.swift
//  AE
//
//  Created by MAC_MINI_6 on 18/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit
import JVFloatLabeledTextField

class ChangePSWVC: BaseVC {

  @IBOutlet weak var tfCurrentPSW: JVFloatLabeledTextField!
  @IBOutlet weak var tfNewPSW: JVFloatLabeledTextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tfResponder = TFResponder()
    tfResponder?.addResponders([.TF(tfCurrentPSW), .TF(tfNewPSW)])
    configureBlocks()
  }
  
  override var canBecomeFirstResponder: Bool {
    return true
  }
  
  override var inputAccessoryView: UIView? {
    return saveAccessory
  }
  
  @IBAction func btnAction(_ sender: UIButton) {
    switch sender.tag {
    case 0: //BACK
      popVC()
    case 1: // Current Password Eye
      sender.setImage(tfCurrentPSW.isSecureTextEntry ? #imageLiteral(resourceName: "ic_eye_1") : #imageLiteral(resourceName: "ic_eye_0"), for: .normal)
      tfCurrentPSW.isSecureTextEntry.toggle()
    case 2: // New Password Eye
      sender.setImage(tfNewPSW.isSecureTextEntry ? #imageLiteral(resourceName: "ic_eye_1") : #imageLiteral(resourceName: "ic_eye_0"), for: .normal)
      tfNewPSW.isSecureTextEntry.toggle()
    default: break
    }
  }
}

//MARK:- VCFuncs
extension ChangePSWVC {
  private func configureBlocks() {
    saveAccessory.didTap = { [weak self] in
      self?.validate()
    }
  }
  
  private func validate() {
    let isValid = Validation.shared.validate(values: (.CURRENT_PSW, /tfCurrentPSW.text?.trimmingCharacters(in: .whitespacesAndNewlines)), (.NEW_PSW, /tfNewPSW.text?.trimmingCharacters(in: .whitespacesAndNewlines)))
    switch isValid {
    case .success:
      changePSWAPIHit()
    case .failure(let type, let message):
      Toast.shared.showAlert(type: type, message: message.localized)
    }
  }
  
  private func changePSWAPIHit() {
    view.endEditing(true)
    EP_Login.changePSW(oldPSW: tfCurrentPSW.text?.trimmingCharacters(in: .whitespacesAndNewlines), newPSW: tfNewPSW.text?.trimmingCharacters(in: .whitespacesAndNewlines)).request(success: { [weak self] (response) in
      Toast.shared.showAlert(type: .success, message: VCLiteral.PSW_CHANGE_SUCCESS.localized)
      self?.popVC()
    })
  }
}
