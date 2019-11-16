//
//  CustomBarButtonItem.swift
//  AE
//
//  Created by MAC_MINI_6 on 19/03/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

enum ItemPosition: Int {
  case left
  case right
}

class SKBarItem: UIBarButtonItem {
  
  var didTapBarButtonItem: (()-> Void)?

  @objc func barButtonItemTapped() {
    didTapBarButtonItem?()
  }
}

extension UIViewController {
  func addBarButtonItemWithImage(on position: ItemPosition, title: String, image: UIImage, attribute: UISemanticContentAttribute, tapped: @escaping (()-> Void)) {
    let button = UIButton(type: .system)
    button.setImage(image, for: .normal)
    button.titleLabel?.font = Fonts.SFProTextBold.ofSize(17)
    button.setTitle(title, for: .normal)
    button.semanticContentAttribute = attribute
    button.sizeToFit()
    let barButtonItem = SKBarItem(customView: button)
    barButtonItem.didTapBarButtonItem = tapped
    switch position {
    case .left:
      navigationItem.leftBarButtonItem = barButtonItem
    case .right:
      navigationItem.rightBarButtonItem = barButtonItem
    }
    button.addTarget(barButtonItem.self, action: #selector(barButtonItem.barButtonItemTapped), for: .touchUpInside)
  }
}
