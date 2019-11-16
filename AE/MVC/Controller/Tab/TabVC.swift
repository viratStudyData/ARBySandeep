//
//  TabVC.swift
//  AE
//
//  Created by MAC_MINI_6 on 08/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

class TabVC: UITabBarController {

  
  var isFirstTime = true
  
  override func viewDidLoad() {
    super.viewDidLoad()
    UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font : Fonts.AvenirNextCondensedMedium.ofSize(11)], for: .normal)
    tabBar.layer.shadowColor = Color.textBlack.value.cgColor
    tabBar.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
    tabBar.layer.shadowRadius = 5
    tabBar.layer.shadowOpacity = 0.5
    tabBar.layer.masksToBounds = false
    tabBar.tintColor = Color.backgroundWhite.value
    
    let vc = UIViewController()
    vc.tabBarItem = UITabBarItem.init(title: nil, image: nil, tag: 2)
    vc.tabBarItem.isEnabled = false
    viewControllers?.insert(vc, at: 2)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(true)
    if isFirstTime {
      addRaisedButton(UIImage(named: "ic_scan"), highlightImage: nil)
    }
    isFirstTime = false
    navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    navigationController?.interactivePopGestureRecognizer?.delegate = self
  }
  
  func addRaisedButton(_ buttonImage: UIImage?, highlightImage: UIImage?) {
    if let buttonImage = buttonImage {
      let button = UIButton(type: UIButton.ButtonType.custom)
      button.tag = 420
      button.autoresizingMask = [UIView.AutoresizingMask.flexibleRightMargin, UIView.AutoresizingMask.flexibleLeftMargin, UIView.AutoresizingMask.flexibleBottomMargin, UIView.AutoresizingMask.flexibleTopMargin]
      
      button.frame = CGRect(x: 0.0, y: 0.0, width: buttonImage.size.width, height: buttonImage.size.height)
      button.setBackgroundImage(buttonImage, for: UIControl.State())
      button.setBackgroundImage(highlightImage, for: UIControl.State.highlighted)
      
      if UIApplication.hasTopNotch {
        button.center = CGPoint.init(x: tabBar.bounds.width / 2, y: (tabBar.bounds.height / 2) - 16)
      } else {
        button.center = CGPoint.init(x: tabBar.bounds.width / 2, y: tabBar.bounds.height / 2)
      }
      button.addTarget(self, action: #selector(TabVC.onRaisedButton(_:)), for: UIControl.Event.touchUpInside)
      tabBar.addSubview(button)
    }
  }
  
  @objc func onRaisedButton(_ sender: UIButton!) {
    SKMediaPicker.init(type: .AllOptions).permissionCheckForVideoRecording {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
        let destVC = StoryboardScene.Other.CameraVC.instantiate()
        destVC.isScanning = true
        UIApplication.topVC()?.pushVC(destVC)
      })
    }
  }
  
}

//MARK:- Interactive pop gesture recognizer
extension TabVC: UIGestureRecognizerDelegate {
  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    if isKind(of: CameraVC.self) || isKind(of: ShareVideoImgVC.self) || isKind(of: HomeVC.self) || isKind(of: TabVC.self) {
      return false
    }
    return true
  }
  
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return false
  }
}
