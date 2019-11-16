//
//  SaveAccessory.swift
//  AE
//
//  Created by MAC_MINI_6 on 18/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

class SaveAccessory: UIView {
    
    @IBOutlet weak var btn: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    func startButtonAnimation() {
        UIView.animate(withDuration: 1.0, delay: 0, options:
            [UIView.AnimationOptions.allowUserInteraction,
             UIView.AnimationOptions.repeat,
             UIView.AnimationOptions.autoreverse],
                       animations: { [weak self] in
                        self?.btn.backgroundColor = Color.buttonBlue.value
                        self?.btn.backgroundColor = Color.textBlack90.value
            }, completion: nil )
    }
    
    func stopButtonAnimation() {
        btn.backgroundColor = Color.buttonBlue.value
        btn.layer.removeAllAnimations()
    }
    
    
    func setButtonTitle(_ title: String) {
        btn.setTitle(title, for: .normal)
    }
    
    //MARK:- Block to check tap on Continue button
    var didTap: (() -> Void)?
    
    //MARK:- for iPhoneX Spacing bottom
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if #available(iOS 11.0, *) {
            if let window = self.window {
                self.bottomAnchor.constraint(lessThanOrEqualToSystemSpacingBelow: window.safeAreaLayoutGuide.bottomAnchor, multiplier: 1.0).isActive = true
            }
        }
    }
    
    
    @IBAction func btnAction(_ sender: Any) {
        didTap?()
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
