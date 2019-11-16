//
//  ObjectPackageModel.swift
//  AE
//
//  Created by MAC_MINI_6 on 25/05/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import Foundation

class Objects: Codable {
  var data: [Object]?
  var count: Int?
  
}

class Packages: Codable {
  var data: [Package]?
  var count: Int?
}
