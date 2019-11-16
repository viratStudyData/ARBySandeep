//
//  LoginEP.swift
//  AE
//
//  Created by MAC_MINI_6 on 16/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import Foundation
import Moya

enum EP_Login {
  case checkUserExist(emailOrPhone: String?, iso: String?, signUpBy: SignupBy)
  case updateLocation(type: ShowLocationType)
  case userLogin(emailOrPhone: String?, iso: String?, password: String?, signUpBy: SignupBy)
  case userSignUp(name: String?, iso: String?, emailOrPhone: String?, facebookId: String?, imageURL: String?, password: String?, signUpBy: SignupBy, image: UIImage?)
  case verifyAccount(id: String?, type: String?, otp: String?)
  case resendOTP(phoneNumber: String?, iso: String?)
  case changePSW(oldPSW: String?, newPSW: String?)
  case editProfile(name: String?, email: String?, phone: String?, iso: String?, image: UIImage?)
  case forgotPassword(emailPhone: String?, iso: String?, signUpBy: SignupBy)
  case logout
  case syncContacts(contacts: [ContactSynced])
}

extension EP_Login: TargetType, AccessTokenAuthorizable {
  var baseURL: URL {
    return URL(string: APIConstant.basePath)!
  }
  
  var path: String {
    switch self {
    case .checkUserExist(_):
      return APIConstant.checkUserExist
    case .updateLocation(_):
      return APIConstant.updateLocation
    case .userLogin(_):
      return APIConstant.userLogin
    case .userSignUp(_):
      return APIConstant.userSignup
    case .verifyAccount(_):
      return APIConstant.userVerifyAccount
    case .resendOTP(_):
      return APIConstant.resendOTP
    case .changePSW(_):
      return APIConstant.changePSW
    case .editProfile(_):
      return APIConstant.editProfile
    case .forgotPassword(_):
      return APIConstant.forgotPassword
    case .logout:
      return APIConstant.logout
    case .syncContacts(_):
      return APIConstant.syncContacts
    }
  }
  
  var method: Moya.Method {
    switch self {
    case .checkUserExist(_),
         .verifyAccount(_):
      return .get
    default:
      return .post
    }
  }
  
  var sampleData: Data {
    return Data()
  }
  
  var task: Task {
    switch self {
    case .editProfile(_), .userSignUp(_):
      return Task.uploadMultipart(multipartBody ?? [])
    case .syncContacts(let contacts):
      let jsonEncoder = JSONEncoder()
      let jsonData = try? jsonEncoder.encode(contacts)
      let jsonObject = try? JSONSerialization.jsonObject(with: jsonData ?? Data(), options: .allowFragments)
      return Task.requestParameters(parameters: ["phoneNumber": jsonObject!], encoding: parameterEncoding)
    default:
      return Task.requestParameters(parameters: parameters ?? [:], encoding: parameterEncoding)
    }
  }
  
  var headers: [String : String]? {
    switch self {
    case .updateLocation(_),
         .changePSW(_),
         .editProfile(_),
         .logout,
         .syncContacts(_):
      return ["Accept" : "application/json",
              "Authorization":"Bearer " + /UserPreference.shared.data?.accessToken]
    default: return nil
    }
  }
  
  var authorizationType: AuthorizationType {
    return .bearer
  }
  
  //Custom Varaibles
  
  var parameters: [String: Any]? {
    let location = LocationManager.shared.locationData
    let latitude = String(location.latitude)
    let longitude = String(location.longitude)
    let deviceToken = /UserPreference.shared.firebaseToken
    
    switch self {
    case .checkUserExist(let emailOrPhone, let iso, let signUpBy):
      return Parameters.checkUserExist.map(values: [emailOrPhone, iso, signUpBy.rawValue])
    case .updateLocation(let type):
      return Parameters.updateLocation.map(values: [latitude, longitude, type.rawValue])
    case .userLogin(let emailOrPhone, let iso, let password, let signUpBy):
      return Parameters.userLogin.map(values: [emailOrPhone, iso, password, signUpBy.rawValue, latitude, longitude, deviceToken])
    case .userSignUp(let name, let iso, let emailOrPhone, let facebookId, let imageURL, let password, let signUpBy, _):
      return Parameters.userSignUp.map(values: [name, iso, emailOrPhone, facebookId, imageURL, password, signUpBy.rawValue, latitude, longitude, deviceToken])
    case .verifyAccount(let id, let type, let otp):
      return Parameters.userVerifyAccount.map(values: [id, type, otp])
    case .resendOTP(let phoneNumber, let iso):
      return Parameters.resendOTP.map(values: [phoneNumber, iso])
    case .changePSW(let oldPSW, let newPSW):
      return Parameters.changePSW.map(values: [oldPSW, newPSW])
    case .editProfile(let name, let email, let phone, let iso, _):
      return Parameters.editProfile.map(values: [name, email, phone, iso])
    case .forgotPassword(let emailPhone, let iso, let signUpBy):
      return Parameters.forgotPassword.map(values: [emailPhone, iso, signUpBy.rawValue])
    default:
      return [:]
    }
  }
  
  var parameterEncoding: ParameterEncoding {
    switch self {
    case .checkUserExist(_),
         .verifyAccount(_):
      return URLEncoding.queryString
    default:
      return JSONEncoding.default
    }
  }
  
  
  var multipartBody: [MultipartFormData]? {
    switch self {
    case .editProfile(_, _, _, _, let image),
         .userSignUp(_, _, _, _, _, _, _, let image):
      var multiPartData = [MultipartFormData]()
      if let image = image {
        let data = image.jpegData(compressionQuality: 0.5) ?? Data()
        multiPartData.append(MultipartFormData.init(provider: .data(data), name: Keys.imageUrl.rawValue, fileName: "image.jpg", mimeType: "image/jpeg"))
      }
      parameters?.forEach({ (key, value) in
        let tempValue = /(value as? String)
        let data = tempValue.data(using: String.Encoding.utf8) ?? Data()
        multiPartData.append(MultipartFormData.init(provider: .data(data), name: key))
      })
      return multiPartData
    default:
      return []
    }
  }
}
