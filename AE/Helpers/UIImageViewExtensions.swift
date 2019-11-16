//
//  UIImageViewExtensions.swift
//  AE
//
//  Created by MAC_MINI_6 on 26/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import Foundation
import Nuke

extension UIImageView {

  
  func setImageKF(_ imageOrURL: Any?, placeHolder: UIImage? = nil) {
    if let _image = imageOrURL as? UIImage {
      image = _image
    } else if let url = URL(string: /(imageOrURL as? String)) {
      var request = ImageRequest(url: url)
      request.memoryCacheOptions.isWriteAllowed = true
      request.priority = .veryHigh
      Nuke.loadImage(with: request, options: ImageLoadingOptions(placeholder: placeHolder, transition: .fadeIn(duration: 0.33)), into: self)
    } else {
      image = nil
    }
  }
}
