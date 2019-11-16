//
//  CALayerExtension.swift
//  AE
//
//  Created by MAC_MINI_6 on 17/05/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

extension CALayer {
  func animateBorderColor(from startColor: UIColor, to endColor: UIColor, withDuration duration: Double) {
    let colorAnimation = CABasicAnimation(keyPath: "borderColor")
    colorAnimation.fromValue = startColor.cgColor
    colorAnimation.toValue = endColor.cgColor
    colorAnimation.duration = duration
    colorAnimation.repeatCount = CFloat.infinity
    colorAnimation.autoreverses = true
    self.borderColor = endColor.cgColor
    self.add(colorAnimation, forKey: "borderColor")
  }
}
