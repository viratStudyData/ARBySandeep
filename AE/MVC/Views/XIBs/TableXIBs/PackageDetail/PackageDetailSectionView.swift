//
//  PackageDetailSectionView.swift
//  AE
//
//  Created by MAC_MINI_6 on 29/05/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

class PackageDetailSectionView: UITableViewHeaderFooterView, ReusableHeaderFooter {
  
  @IBOutlet weak var lblTitle: UILabel!
  
  typealias T = HeaderFooterData

  var item: HeaderFooterData? {
    didSet {
      
    }
  }
  
}
