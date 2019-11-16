//
//  ShowLocationHeader.swift
//  AE
//
//  Created by MAC_MINI_6 on 17/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

class ShowLocationHeader: UITableViewHeaderFooterView, ReusableHeaderFooter {
  
  typealias T = HeaderFooterData
  
  @IBOutlet weak var lblTitle: UILabel!
  @IBOutlet weak var switchOnOff: UISwitch!
  
  var didChangeSwitch: ((_ isOn: Bool) -> Void)?
  
  var item: HeaderFooterData? {
    didSet {
//      lblTitle.text = item?.other?.title
      let locationType = UserPreference.shared.data?.showLocation ?? .NONE
      switchOnOff.setOn(locationType != .NONE, animated: true)
    }
  }
  
  
  @IBAction func switchAction(_ sender: UISwitch) {
    didChangeSwitch?(sender.isOn)
  }
}
