//
//  SearchSection.swift
//  AE
//
//  Created by MAC_MINI_6 on 24/05/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

class SearchSection: UITableViewHeaderFooterView, ReusableHeaderFooter {
  
  typealias T = HeaderFooterData
  
  @IBOutlet weak var lblTitle: UILabel!
  
  var item: HeaderFooterData? {
    didSet {
      lblTitle.text = /item?.other?.title
    }
  }
}
