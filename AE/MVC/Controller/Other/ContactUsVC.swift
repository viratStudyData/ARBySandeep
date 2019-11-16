//
//  ContactUsVC.swift
//  AE
//
//  Created by MAC_MINI_6 on 25/05/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit
import PhoneNumberKit

class ContactUsVC: BaseVC {

  @IBOutlet weak var tfTextView: UITextView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tfTextView.textContainerInset = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
  }
  
  @IBAction func btnAction(_ sender: UIButton) {
    switch sender.tag {
    case 0: // Back
      popVC()
    case 1: // Send Message
      let isValid = Validation.shared.validate(values: (ValidationType.CONTACT_US, /tfTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)))
      switch isValid {
      case .success:
        tfTextView.resignFirstResponder()
        contactUsAPI()
      case .failure(let type, let message):
        Toast.shared.showAlert(type: type, message: message.localized)
      }
    case 2: // Call company
      phoneServices.call(to: /UserPreference.shared.appDefaults?.contactAdmin)
    case 3: // Mail Company
      phoneServices.mail(to: ["\(/UserPreference.shared.appDefaults?.emailAdmin)"])
    default:
      break
    }
  }
  
}

//MARK:- VCFuncs
extension ContactUsVC {
  private func contactUsAPI() {
    EP_Other.contactUs(message: tfTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)).request(success: { [weak self] (response) in
      self?.popVC()
      Toast.shared.showAlert(type: .success, message: VCLiteral.CONTACT_US_MESSAGE_SENT.localized)
    }) { (error) in
      Toast.shared.showAlert(type: .apiFailure, message: /error)
    }
  }
}
