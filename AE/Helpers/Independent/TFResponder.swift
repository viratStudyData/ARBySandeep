//
//  TFResponder.swift
//  AE
//
//  Created by MAC_MINI_6 on 19/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

enum TVTF {
  case TV(UITextView)
  case TF(UITextField)
}

class TFResponder: NSObject {
  
  private var tvOrTfs: [TVTF]?
  var isFieldResigned: ((_ isResigned: Bool) -> Void)?

  override init() {
    super.init()
  }
  
  public func addResponders(_ array: [TVTF]) {
    tvOrTfs = array
    for (index, inputType) in (tvOrTfs ?? []).enumerated() {
      addDelegateAndReturnType(item: inputType, returnType: index == ((tvOrTfs?.count ?? 0) - 1) ? .done : .next)
    }
  }
  
  private func addDelegateAndReturnType(item: TVTF, returnType: UIReturnKeyType) {
    switch item {
    case .TF(let textField):
      textField.returnKeyType = returnType
      textField.delegate = self
    case .TV(let textView):
      textView.returnKeyType = returnType
      textView.delegate = self
    }
  }
}

//MARK:- UITextField Deleagates
extension TFResponder: UITextFieldDelegate {
  internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    //Magic code if textfield is last then resign else becomeFirstResponder to next TextField
    var selectedIndex = 0
    for (index, inputType) in (tvOrTfs ?? []).enumerated() {
      switch inputType {
      case .TF(let tF):
        if textField == tF {
          selectedIndex = index
        }
      case .TV(_):
        break
      }
    }
    
    switch tvOrTfs?.last ?? .TF(UITextField()) {
    case .TF(let tf):
      if textField == tf {
        textField.resignFirstResponder()
      } else {
        switch tvOrTfs?[selectedIndex + 1] ?? .TF(UITextField()) {
        case .TF(let tfNext):
          tfNext.becomeFirstResponder()
        case .TV(let tvNext):
          tvNext.becomeFirstResponder()
        }
      }
    case .TV(_):
      break
    }
    return true
  }
  
  
  internal func textFieldDidBeginEditing(_ textField: UITextField) {
    isFieldResigned?(false)
  }
  
  internal func textFieldDidEndEditing(_ textField: UITextField) {
    isFieldResigned?(true)
  }
}

//MARK:- UITextView Delegates
extension TFResponder: UITextViewDelegate {
  internal func textViewDidBeginEditing(_ textView: UITextView) {
    isFieldResigned?(false)
  }
  
  internal func textViewDidEndEditing(_ textView: UITextView) {
    isFieldResigned?(true)
  }
}
