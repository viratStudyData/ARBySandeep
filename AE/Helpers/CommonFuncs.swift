//
//  CommonFuncs.swift
//  AE
//
//  Created by MAC_MINI_6 on 28/03/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit


class CommonFuncs {
  
  static let shared = CommonFuncs()
  
  func isUserLoggedIn(showPopUp: Bool? = false, canBeCancelled: Bool) -> Bool {
    let valueToReturn = !(UserPreference.shared.data == nil)
    if /showPopUp && !valueToReturn {
      let popUpVC = StoryboardScene.PopUp.LoginPopUpVC.instantiate()
      popUpVC.canBeCanceled = canBeCancelled
      UIApplication.topVC()?.presentPopUp(popUpVC)
    }
    return valueToReturn
  }
  
  func storyboardReInstantiateFor(_ purpose: ReInstantiatePurpose) {
    switch purpose {
    case .Logout, .SessionExpired:
      UserPreference.shared.data = nil
      SocketIOManager.shared.closeConnection()
      //clear User defaults, notification count and any other data
    default:
      break
    }
    let window = UIApplication.shared.delegate?.window
    window??.rootViewController = purpose.vcLinked
    window??.backgroundColor = UIColor.white
    window??.makeKeyAndVisible()
    UIView.transition(with: window!!, duration: 0.4, options: UIView.AnimationOptions.transitionCrossDissolve, animations: {
    }, completion: { _ in })
  }
  
  func termsAndConditions() -> NSMutableAttributedString {
    let termsStartAttr: [NSAttributedString.Key : Any] = [NSAttributedString.Key.foregroundColor : Color.textBlack.value,
                                                            NSAttributedString.Key.font : Fonts.SFProTextLight.ofSize(12)]
    let termsEndAttr: [NSAttributedString.Key : Any] = [NSAttributedString.Key.foregroundColor : Color.textBlue.value,
                                                          NSAttributedString.Key.font : Fonts.SFProTextHeavy.ofSize(12)]
    
    let termsText1 = NSMutableAttributedString(string: VCLiteral.TERMS_START.localized, attributes: termsStartAttr)
    let termsText2 = NSMutableAttributedString(string: VCLiteral.TERMS_END.localized, attributes: termsEndAttr)
    termsText1.append(termsText2)
    return termsText1
  }
}
