//
//  Fonts.swift
//  AE
//
//  Created by MAC_MINI_6 on 18/03/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

enum Fonts: String {
  case SFProDisplayBlack = "SFProDisplay-Black"
  case SFProDisplayBlackItalic = "SFProDisplay-BlackItalic"
  case SFProDisplayBold = "SFProDisplay-Bold"
  case SFProDisplayBoldItalic = "SFProDisplay-BoldItalic"
  case SFProDisplayHeavy = "SFProDisplay-Heavy"
  case SFProDisplayHeavyItalic = "SFProDisplay-HeavyItalic"
  case SFProDisplayLight = "SFProDisplay-Light"
  case SFProDisplayLightItalic = "SFProDisplay-LightItalic"
  case SFProDisplayMedium = "SFProDisplay-Medium"
  case SFProDisplayMediumItalic = "SFProDisplay-MediumItalic"
  case SFProDisplayRegular = "SFProDisplay-Regular"
  case SFProDisplayRegularItalic = "SFProDisplay-RegularItalic"
  case SFProDisplaySemibold = "SFProDisplay-Semibold"
  case SFProDisplaySemiboldItalic = "SFProDisplay-SemiboldItalic"
  case SFProDisplayThin = "SFProDisplay-Thin"
  case SFProDisplayThinItalic = "SFProDisplay-ThinItalic"
  case SFProDisplayUltralight = "SFProDisplay-Ultralight"
  case SFProDisplayUltralightItalic = "SFProDisplay-UltralightItalic"
  case SFProTextBold = "SFProText-Bold"
  case SFProTextBoldItalic = "SFProText-BoldItalic"
  case SFProTextHeavy = "SFProText-Heavy"
  case SFProTextHeavyItalic = "SFProText-HeavyItalic"
  case SFProTextLight = "SFProText-Light"
  case SFProTextLightItalic = "SFProText-LightItalic"
  case SFProTextMedium = "SFProText-Medium"
  case SFProTextMediumItalic = "SFProText-MediumItalic"
  case SFProTextRegular = "SFProText-Regular"
  case SFProTextRegularItalic = "SFProText-RegularItalic"
  case SFProTextSemibold = "SFProText-Semibold"
  case SFProTextSemiboldItalic = "SFProText-SemiboldItalic"
  case AvenirNextCondensedMedium = "AvenirNextCondensed-Medium"
  
  func ofSize(_ value: CGFloat) -> UIFont {
    return UIFont(name: self.rawValue, size: value) ?? UIFont.systemFont(ofSize: value)
  }
}
