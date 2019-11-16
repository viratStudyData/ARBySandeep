//
//  TableProtocols.swift
//  AE
//
//  Created by MAC_MINI_6 on 08/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

struct HeaderFooterValues { //Do not change this
  var headerIdentifier: String
  var headerHeight: CGFloat
  var cellIdentifier: String
  var cellHeight: CGFloat
  var footerIdentifier: String
  var footerHeight: CGFloat
}

struct OtherHeaderFooterProperty { //Add extra properties for Header and footer views if need to access
  var title: String
  var subTitle: String
  var isViewAllVisible: Bool
}

protocol HeaderFooterDataProvider {
  var property: HeaderFooterValues? { get set }
  var items: [Any]? { get set } //Cell Items
  var other: OtherHeaderFooterProperty? { get set }
  
  init(_property: HeaderFooterValues?, _items: [Any]?, _other: OtherHeaderFooterProperty?)
}

protocol ReusableCell {
  static var identfier: String { get }
  var item: Any? { get set }
}

extension ReusableCell {
  static var identfier: String {
    return String.init(describing: self)
  }
}

protocol ReusableHeaderFooter {
  associatedtype T : HeaderFooterDataProvider
  static var identfier: String { get }
  var item: T? { get set }
}

extension ReusableHeaderFooter {
  static var identfier: String {
    return String.init(describing: self)
  }
}

class HeaderFooterData: HeaderFooterDataProvider {
  var property: HeaderFooterValues?
  var items: [Any]?
  var other: OtherHeaderFooterProperty?
  
  required init(_property: HeaderFooterValues?, _items: [Any]?, _other: OtherHeaderFooterProperty?) {
    property = _property
    items = _items
    other = _other
  }

  class func getSingleSectionItems(items: [Any], id: String, height: CGFloat) -> [HeaderFooterData] {
    return [HeaderFooterData.init(_property: HeaderFooterValues.init(headerIdentifier: "", headerHeight: 0.0001, cellIdentifier: id, cellHeight: height, footerIdentifier: "", footerHeight: 0.0001), _items: items, _other: nil)]
  }
}

