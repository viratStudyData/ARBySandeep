//
//  UIApplicationExtensions.swift
//  AE
//
//  Created by MAC_MINI_6 on 19/03/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

extension UIApplication {
  class func topVC(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
    if let navigationController = controller as? UINavigationController {
      return topVC(controller: navigationController.visibleViewController)
    }
    if let tabController = controller as? UITabBarController {
      if let selected = tabController.selectedViewController {
        return topVC(controller: selected)
      }
    }
    if let presented = controller?.presentedViewController {
      return topVC(controller: presented)
    }
    return controller
  }
  
  static var hasTopNotch: Bool {
    if #available(iOS 11.0, tvOS 11.0, *) {
      return self.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
    }
    return false
  }
  
  var isKeyboardPresented: Bool {
    if let keyboardWindowClass = NSClassFromString("UIRemoteKeyboardWindow"), self.windows.contains(where: { $0.isKind(of: keyboardWindowClass) }) {
      return true
    } else {
      return false
    }
  }
  
  static var statusBarHeight: CGFloat {
    if #available(iOS 11.0, tvOS 11.0, *) {
      let value = self.shared.delegate?.window??.safeAreaInsets.top ?? 0
      return value == 0 ? 20.0 : value
    } else {
      return 20.0
    }
  }
  

  
}
