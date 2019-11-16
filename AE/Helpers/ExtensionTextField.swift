//
//  ExtensionTextField.swift
//  AE
//
//  Created by MAC_MINI_6 on 24/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit
import JVFloatLabeledTextField

private var __maxLengths = [UITextField: Int]()

extension UITextField {
  @IBInspectable var maxLength: Int {
    get {
      guard let l = __maxLengths[self] else {
        return 150
      }
      return l
    }
    set {
      __maxLengths[self] = newValue
      addTarget(self, action: #selector(fix), for: .editingChanged)
    }
  }
  
  @objc func fix(textField: UITextField) {
    let text = textField.text
    textField.text = text?.safelyLimitedTo(length: maxLength)
  }
  
  @IBInspectable var placeHolderColor: UIColor? {
    get {
      return self.placeHolderColor
    }
    set {
      self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
    }
  }
  
}

extension String
{
  func safelyLimitedTo(length n: Int)->String {
    let c = self
    if (c.count <= n) { return self }
    return String( Array(c).prefix(upTo: n) )
  }
  
}


enum ResponderStandardEditActions {
  case cut, copy, paste, select, selectAll, delete
  case makeTextWritingDirectionLeftToRight, makeTextWritingDirectionRightToLeft
  case toggleBoldface, toggleItalics, toggleUnderline
  case increaseSize, decreaseSize
  
  var selector: Selector {
    switch self {
    case .cut:
      return #selector(UIResponderStandardEditActions.cut)
    case .copy:
      return #selector(UIResponderStandardEditActions.copy)
    case .paste:
      return #selector(UIResponderStandardEditActions.paste)
    case .select:
      return #selector(UIResponderStandardEditActions.select)
    case .selectAll:
      return #selector(UIResponderStandardEditActions.selectAll)
    case .delete:
      return #selector(UIResponderStandardEditActions.delete)
    case .makeTextWritingDirectionLeftToRight:
      return #selector(UIResponderStandardEditActions.makeTextWritingDirectionLeftToRight)
    case .makeTextWritingDirectionRightToLeft:
      return #selector(UIResponderStandardEditActions.makeTextWritingDirectionRightToLeft)
    case .toggleBoldface:
      return #selector(UIResponderStandardEditActions.toggleBoldface)
    case .toggleItalics:
      return #selector(UIResponderStandardEditActions.toggleItalics)
    case .toggleUnderline:
      return #selector(UIResponderStandardEditActions.toggleUnderline)
    case .increaseSize:
      return #selector(UIResponderStandardEditActions.increaseSize)
    case .decreaseSize:
      return #selector(UIResponderStandardEditActions.decreaseSize)
    }
  }
  
}

class CustomTF: JVFloatLabeledTextField {
  
  var didPressBackWard: (() -> Void)?
  
  override func deleteBackward() {
    super.deleteBackward()
    didPressBackWard?()
  }
  
  var allowedActions: [ResponderStandardEditActions] = [] {
    didSet {
      if !allowedActions.isEmpty && !notAllowedActions.isEmpty {
        notAllowedActions = []
      }
    }
  }
  
  var notAllowedActions: [ResponderStandardEditActions] = [] {
    didSet {
      if !allowedActions.isEmpty && !notAllowedActions.isEmpty {
        allowedActions = []
      }
    }
  }
  
  open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
    if !allowedActions.isEmpty {
      return allowedActions.map{ $0.selector }.contains(action)
    }
    
    if !notAllowedActions.isEmpty {
      return !notAllowedActions.map{ $0.selector }.contains(action)
    }
    return super.canPerformAction(action, withSender: sender)
  }
  
}
