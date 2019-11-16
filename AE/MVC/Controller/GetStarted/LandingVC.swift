//
//  LandingVC.swift
//  AE
//
//  Created by MAC_MINI_6 on 19/03/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

class LandingVC: BaseVC {
  //MARK:- IBOutlets
  @IBOutlet weak var lblTerms: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    lblTerms.attributedText = CommonFuncs.shared.termsAndConditions()
    if /UserPreference.shared.data?.isVerified == true {
      CommonFuncs.shared.storyboardReInstantiateFor(.SuccessLogin)
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(true)
    LocationManager.shared.startTrackingUser()
  }
  
  //MARK:- IBActions
  @IBAction func btnGetStartedAction(_ sender: UIButton) {
    let destVC = StoryboardScene.GetStarted.SignUpVC.instantiate()
    pushVC(destVC)
  }
  
  @IBAction func btnSkipAction(_ sender: UIButton) {
    CommonFuncs.shared.storyboardReInstantiateFor(.GuestLogin)
  }
}
