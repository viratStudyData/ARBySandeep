//
//  Operators.swift
//  EliteMotorsClub
//
//  Created by MAC_MINI_6 on 17/01/19.
//  Copyright © 2019 Code-BrewLabs. All rights reserved.
//

import UIKit

protocol OptionalType { init() }

//MARK:- EXTENSIONS
extension String: OptionalType {}
extension Int: OptionalType {}
extension Double: OptionalType {}
extension Bool: OptionalType {}
extension Float: OptionalType {}
extension CGFloat: OptionalType {}
extension CGRect: OptionalType {}
extension UIImage: OptionalType {}
extension IndexPath: OptionalType {}
extension Int64: OptionalType {}

prefix operator /

// provides shortcut to upwrap optional variables with their default value.
prefix func /<T: OptionalType>( value: T?) -> T {
  guard let validValue = value else { return T() }
  return validValue
}
