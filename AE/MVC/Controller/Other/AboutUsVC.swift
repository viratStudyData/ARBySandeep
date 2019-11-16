//
//  AboutUsVC.swift
//  AE
//
//  Created by MAC_MINI_6 on 25/05/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit
import WebKit

class AboutUsVC: BaseVC {
  
  @IBOutlet weak var wkView: WKWebView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if let url = URL(string: /UserPreference.shared.appDefaults?.aboutUs) {
      let request = URLRequest(url: url)
      wkView.load(request)
    }
//    wkView.uiDelegate = self
//    if let url = URL(string: "https://business.gasitup.com/#/chasepay_payement?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI1Y2YwZGE3MDRkYTIzMTY2NTlkNTI4NDIiLCJ0eXBlIjoiVVNFUiIsImlhdCI6MTU2MjU5MjYzOH0.KVHLcktCs4AI3tk1q4ynTkp7W5Z1GeoCspvawYYm0jE") {
//      let request = URLRequest(url: url)
//      wkView.load(request)
//    }
    
    
  }
  
  @IBAction func btnBackAction(_ sender: UIButton) {
    popVC()
  }
  
}
