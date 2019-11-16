//
//  EditProfileVC.swift
//  AE
//
//  Created by MAC_MINI_6 on 19/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit
import JVFloatLabeledTextField

class EditProfileVC: BaseVC {

  @IBOutlet weak var imgWidth: NSLayoutConstraint!
  @IBOutlet weak var imgProfile: UIImageView!
  @IBOutlet weak var imgBackView: UIView!
  @IBOutlet weak var tfFullName: JVFloatLabeledTextField!
  @IBOutlet weak var tfEmail: JVFloatLabeledTextField!
  @IBOutlet weak var tfPhone: JVFloatLabeledTextField!
  @IBOutlet weak var btnCC: UIButton!
  
  private var currentCountry: CountryISO?
  private var isImageChanged: Bool = false
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    initialUIAndDataSetup()
    saveAccessory.didTap = { [weak self] in
      self?.validate()
    }
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(true)
  }
  
  override var inputAccessoryView: UIView? {
    return saveAccessory
  }

  override var canBecomeFirstResponder: Bool {
    return false
  }
  
  @IBAction func btnAction(_ sender: UIButton) {
    switch sender.tag {
    case 0: //Back
      popVC()
    case 1: //CountryCode
      view.endEditing(true)
      CountryManager.shared.openCountryPicker { [weak self] (country) in
        self?.currentCountry = country
        sender.setTitle("\(country?.Flag ?? "") +\(country?.CC ?? "")", for: .normal)
      }
    case 2: //Camera
      mediaPicker.pickerType = .ImageCameraLibrary
      mediaPicker.presentPicker({ [weak self] (pickedImage) in
        self?.isImageChanged = true
        self?.imgProfile.image = pickedImage
      })
    case 3: //Save
      validate()
    default:
      break
    }
  }
}

//MARK:- VCFuncs
extension EditProfileVC {
  func initialUIAndDataSetup() {
    let widthOfProfile = ScreenSize.SCREEN_WIDTH * 0.4
    imgWidth.constant = widthOfProfile
    imgProfile.cornerRadius = widthOfProfile / 2
    imgBackView.cornerRadius = (widthOfProfile / 2) + 1
    tfResponder = TFResponder()
    let userData = UserPreference.shared.data
    
    currentCountry = CountryISO(/userData?.phoneNumber?.countryCode, CountryManager.shared.flag(country: /userData?.phoneNumber?.ISO), /userData?.phoneNumber?.ISO)
    if /userData?.phoneNumber?.phoneNo == "" {
      currentCountry = CountryManager.shared.currentCountry
    }
    imgProfile.setImageKF(UserPreference.shared.data?.imageUrl?.thumbnail, placeHolder: #imageLiteral(resourceName: "ic_profile_placeholder"))    
    btnCC.setTitle("\(currentCountry?.Flag ?? "") +\(currentCountry?.CC ?? "")", for: .normal)
    tfPhone.text = /userData?.phoneNumber?.phoneNo
    tfFullName.text = /userData?.name
    tfEmail.text = /userData?.email
    switch SignupBy(rawValue: /userData?.signUpBy) ?? .FACEBOOK {
    case .FACEBOOK:
      tfResponder?.addResponders([.TF(tfFullName), .TF(tfEmail), .TF(tfPhone)])
      tfPhone.isUserInteractionEnabled = false
      btnCC.isUserInteractionEnabled = false
      tfEmail.isUserInteractionEnabled = false
    case .EMAIL:
      tfEmail.isUserInteractionEnabled = false
      tfResponder?.addResponders([.TF(tfFullName), .TF(tfPhone)])
    case .PHONE_NUMBER:
      tfPhone.isUserInteractionEnabled = false
      btnCC.isUserInteractionEnabled = false
      tfResponder?.addResponders([.TF(tfFullName), .TF(tfEmail)])
    }
    
  }
  
  func validate() {
    let isValid = Validation.shared.validate(values: (ValidationType.NAME, /tfFullName.text))
    switch isValid {
    case .success:
      editProfileAPI()
    case .failure(let type, let message):
      Toast.shared.showAlert(type: type, message: message.localized)
    }
  }
  
  func editProfileAPI() {
    var phoneNumber: String?
    if /tfPhone.text?.trimmingCharacters(in: CharacterSet.whitespaces) != "" {
      phoneNumber = "\(/currentCountry?.CC)\(/tfPhone.text)"
    }
    phoneNumber =  /phoneNumber == "" ? "   " : /phoneNumber
    view.endEditing(true)
    
    EP_Login.editProfile(name: tfFullName.text, email: /tfEmail.text == "" ? "   " : /tfEmail.text, phone: /phoneNumber, iso: currentCountry?.ISO,image: isImageChanged ? imgProfile.image : nil).request(success: { [weak self] (response) in
      let data = (response as? UserData)
      let tempData = UserPreference.shared.data
      tempData?.name = data?.name
      tempData?.phoneNumber = data?.phoneNumber
      tempData?.email = data?.email
      tempData?.imageUrl = data?.imageUrl
      UserPreference.shared.data = tempData
      Toast.shared.showAlert(type: AlertType.success, message: VCLiteral.PROFILE_UPDATED.localized)
      self?.popVC()
    }) { (error) in
      
    }
  }
}
