//
//  UserMarkerSelected.swift
//  AE
//
//  Created by MAC_MINI_6 on 21/05/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

class UserMarkerSelected: UIView {

  @IBOutlet weak var imgUser: UIImageView!
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.bounds = frame
    setupView()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupView()
    fatalError("init(coder:) has not been implemented")
  }
  
  var item: UserData? {
    didSet {
      imgUser.setImageKF(item?.imageUrl?.thumbnail)
      bringSubviewToFront(imgUser)
    }
  }
  
  // Performs the initial setup.
  private func setupView() {
    let view = viewFromNibForClass()
    addSubview(view)
  }
  
  // Loads a XIB file into a view and returns this view.
  private func viewFromNibForClass() -> UIView {
    let bundle = Bundle(for: type(of: self))
    let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
    let view = nib.instantiate(withOwner: self, options: nil)
    return view.first as? UIView ?? UIView()
  }

}
