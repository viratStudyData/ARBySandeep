//
//  ContinueAccessory.swift
//  AE
//
//  Created by MAC_MINI_6 on 25/03/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

class ContinueAccessory: UIView {
  
  @IBOutlet weak var btn: UIButton!
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupView()
  }
  
  //MARK:- Block to check tap on Continue button
  var didTapContinue: (() -> Void)?
  
  //MARK:- for iPhoneX Spacing bottom
  override func didMoveToWindow() {
    super.didMoveToWindow()
    if #available(iOS 11.0, *) {
      if let window = self.window {
        self.bottomAnchor.constraint(lessThanOrEqualToSystemSpacingBelow: window.safeAreaLayoutGuide.bottomAnchor, multiplier: 1.0).isActive = true
      }
    }
  }
  
  @IBAction func btnContinueAction(_ sender: Any) {
    didTapContinue?()
  }
  
  func setTitle(_ type: AccessoryTitle) {
    btn.setTitle(type.title, for: .normal)
  }
  
  // Performs the initial setup.
  private func setupView() {
    let view = viewFromNibForClass()
    view.frame = bounds
    view.autoresizingMask = [
      UIView.AutoresizingMask.flexibleWidth,
      UIView.AutoresizingMask.flexibleHeight
    ]
    addSubview(view)
    // to dynamically increase height of text view
    // http://ticketmastermobilestudio.com/blog/translating-autoresizing-masks-into-constraints
    //if textView.translatesAutoresizingMaskIntoConstraints = true then height will not increase automatically
    // translatesAutoresizingMaskIntoConstraints default = true
  }
  
  // Loads a XIB file into a view and returns this view.
  private func viewFromNibForClass() -> UIView {
    let bundle = Bundle(for: type(of: self))
    let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
    let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
    return view
  }
}
