//
//  Validation.swift
//  AE
//
//  Created by MAC_MINI_6 on 03/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

//MARK:- Alert Types
enum AlertType: String {
  case success = "SUCCESS"
  case apiFailure = "API_FAILURE"
  case validationFailure = "VALIDATION_FAILURE"
  case notification = "NOTICATION_TITLE"
  
  var title: String {
    return NSLocalizedString(self.rawValue, comment: "")
  }
  
  var color: UIColor {
    return Color.buttonBlue.value
    
//    switch self {
//    case .validationFailure:
//      return Color.buttonBlue.value
//    case .apiFailure:
//      return Color.gradient1.value
//    case .success:
//      return Color.success.value
//    }
  }
}

//MARK:- Alert messages to be appeared on failure
enum AlertMessage: String {
  case EMPTY_EMAIL_PHONE = "EMPTY_EMAIL_PHONE"
  case EMPTY_EMAIL = "EMPTY_EMAIL"
  case INVALID_EMAIL = "INVALID_EMAIL"
  case INVALID_PHONE = "INVALID_PHONE"
  case INVALID_EMAIL_PHONE = "INVALID_EMAIL_PHONE"
  
  case EMPTY_PASSWORD = "EMPTY_PASSWORD"
  case EMPTY_PHONE = "EMPTY_PHONE"
  case INVALID_PASSWORD = "INVALID_PASSWORD"
  
  case EMPTY_CONFIRM_PASSWORD = "EMPTY_CONFIRM_PASSWORD"
  case INVALID_CONFIRM_PASSWORD = "INVALID_CONFIRM_PASSWORD"
  case PASSWORD_NOT_MATCH = "PASSWORD_NOT_MATCH"
  
  case EMPTY_NAME = "EMPTY_NAME"
  case EMPTY_CONTACT_US = "EMPTY_CONTACT_US"
  case INVALID_NAME = "INVALID_NAME"
  
  case EMPTY_CURRENT_PSW = "EMPTY_CURRENT_PSW"
  case EMPTY_NEW_PSW = "EMPTY_NEW_PSW"
  case INVALID_CURRENT_PSW = "INVALID_CURRENT_PSW"
  case INVALID_NEW_PSW = "INVALID_NEW_PSW"
  case EMPTY_OTP = "EMPTY_OTP"
  
  var localized: String {
    return NSLocalizedString(self.rawValue, comment: "")
  }
}

//MARK:- Check validation failed or not
enum Valid {
  case success
  case failure(AlertType, AlertMessage)
}

//MARK:- RegExes used to validate various things
enum RegEx: String {
  case EMAIL = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}" // Email
  case PASSWORD = "^.{6,100}$" // Password length 6-100
  case NAME = "^[A-Z]+[a-zA-Z]*$" // SandsHell
  case PHONE_NO = "(?!0{5,15})^[0-9]{5,15}" // PhoneNo 5-15 Digits
  case EMAIL_OR_PHONE = ""
  case All = "ANY_TEXT"
}

//MARK:- Validation Type Enum to be used with value that is to be validated when calling validate function of this class
enum ValidationType {
  case EMAIL
  case PHONE
  case EMAIL_OR_PHONE
  case NAME
  case PASSWORD
  case CONFIRM_PASSWORD
  case CURRENT_PSW
  case NEW_PSW
  case LOGIN_PSW
  case EMAIL_OR_PHONE_FORGOT_PSW
  case CONTACT_US
}

class Validation {
  //MARK:- Shared Instance
  static let shared = Validation()
  
  func validate(values: (type: ValidationType, input: String)...) -> Valid {
    for valueToBeChecked in values {
      switch valueToBeChecked.type {
      case .EMAIL:
        if let tempValue = isValidString((valueToBeChecked.input, .EMAIL, .EMPTY_EMAIL, .INVALID_EMAIL)) {
          return tempValue
        }
      case .PHONE:
        if let tempValue = isValidString((valueToBeChecked.input, .PHONE_NO, .EMPTY_PHONE, .INVALID_PHONE)) {
          return tempValue
        }
      case .EMAIL_OR_PHONE:
        if let tempValue = isValidString((valueToBeChecked.input, .EMAIL_OR_PHONE, .EMPTY_EMAIL_PHONE, .INVALID_EMAIL_PHONE)) {
          if /valueToBeChecked.input.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return tempValue
          } else if /valueToBeChecked.input.isNumeric {
            return Valid.failure(.validationFailure, AlertMessage.INVALID_PHONE)
          } else {
            return Valid.failure(.validationFailure, AlertMessage.INVALID_EMAIL)
          }
        }
      case .EMAIL_OR_PHONE_FORGOT_PSW:
        if let tempValue = isValidString((valueToBeChecked.input, .EMAIL_OR_PHONE, .EMPTY_EMAIL_PHONE, .INVALID_EMAIL_PHONE)) {
          return tempValue
        }
      case .NAME:
        if let tempValue = isValidString((valueToBeChecked.input, .All, .EMPTY_NAME, .INVALID_NAME)) {
          return tempValue
        }
      case .CONTACT_US:
        if let tempValue = isValidString((valueToBeChecked.input, .All, .EMPTY_CONTACT_US, .INVALID_NAME)) {
          return tempValue
        }
      case .PASSWORD:
        if let tempValue = isValidString((valueToBeChecked.input, .PASSWORD, .EMPTY_PASSWORD, .INVALID_PASSWORD)) {
          return tempValue
        }
      case .LOGIN_PSW:
        if let tempValue = isValidString((valueToBeChecked.input, .All, .EMPTY_PASSWORD, .INVALID_PASSWORD)) {
          return tempValue
        }
      case .CONFIRM_PASSWORD:
        if let tempValue = isValidString((valueToBeChecked.input, .All, .EMPTY_CONFIRM_PASSWORD, .INVALID_CONFIRM_PASSWORD)) {
          return tempValue
        }
      case .CURRENT_PSW:
        if let tempValue = isValidString((valueToBeChecked.input, .PASSWORD, .EMPTY_CURRENT_PSW, .INVALID_CURRENT_PSW)) {
          return tempValue
        }
      case .NEW_PSW:
        if let tempValue = isValidString((valueToBeChecked.input, .PASSWORD, .EMPTY_NEW_PSW, .INVALID_NEW_PSW)) {
          return tempValue
        }
      }
     }
    return .success
  }
  
  private func isValidString(_ input: (text: String, regex: RegEx, emptyAlert: AlertMessage, invalidAlert: AlertMessage)) -> Valid? {
    if (input.regex == .PHONE_NO) && (input.text != "") && Int(input.text) == 0 {
      return .failure(.validationFailure, AlertMessage.INVALID_PHONE)
    }
    
    if /input.text.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
      return .failure(.validationFailure, input.emptyAlert)
    } else if isValidRegEx(input.text, input.regex) != true {
      return .failure(.validationFailure, input.invalidAlert)
    }
    return nil
  }
  //MARK:- Validating input value with RegEx
  private func isValidRegEx(_ testStr: String, _ regex: RegEx) -> Bool {
    let stringTest = NSPredicate(format:"SELF MATCHES %@", regex.rawValue)
    let result = stringTest.evaluate(with: testStr)
    if regex == .EMAIL_OR_PHONE {
      return validateForEmailOrPhoneNumber(testStr, emailRegEx: .EMAIL, phoneRegEx: .PHONE_NO)
    } else if regex == .All {
      return true
    } else if regex == .EMAIL {
      return !((/testStr).first == ".") && result
    } else {
      return result
    }
  }
  //MARK:- Special method to validate email and phone number in one field
  private func validateForEmailOrPhoneNumber(_ stringToTest: String, emailRegEx: RegEx, phoneRegEx: RegEx) -> Bool {
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx.rawValue)
    let phoneText = NSPredicate(format:"SELF MATCHES %@", phoneRegEx.rawValue)
    return ((emailTest.evaluate(with: stringToTest)) && !((/stringToTest).first == ".")) || phoneText.evaluate(with: stringToTest)
  }
}
