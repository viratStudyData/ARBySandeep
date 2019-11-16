//
//  LoginPopUpVC.swift
//  AE
//
//  Created by MAC_MINI_6 on 17/05/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

class LoginPopUpVC: UIViewController {

  @IBOutlet weak var mainView: UIView!
  @IBOutlet weak var btnContinue: UIButton!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    startPopUpWithAnimation()
    
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(true)
    animateButton()
  }
  
  var canBeCanceled = false
  
  @IBAction func btnContnueAction(_ sender: UIButton) {
    removePopUp()
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
      CommonFuncs.shared.storyboardReInstantiateFor(.Logout)
    }
  }
  
  @IBAction func btnRemovePopUpAction(_ sender: UIButton) {
    canBeCanceled ? removePopUp() : ()
  }
  
    func animateButton() {
      
      mainView.layer.animateBorderColor(from: Color.buttonBlue.value, to: Color.textBlack90.value, withDuration: 1.0)
      UIView.animate(withDuration: 1.0, delay: 0, options:
        [UIView.AnimationOptions.allowUserInteraction,
         UIView.AnimationOptions.repeat,
         UIView.AnimationOptions.autoreverse],
                                 animations: { [weak self] in
                                  self?.btnContinue.backgroundColor = Color.buttonBlue.value
                                  self?.btnContinue.backgroundColor = Color.textBlack90.value
      }, completion: nil )
    }
  
}


