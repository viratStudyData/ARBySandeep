//
//  UIScrollViewExtensions.swift
//  AE
//
//  Created by MAC_MINI_6 on 04/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

extension UITableView {
  func sizeHeaderToFit() {
    let headerView = self.tableHeaderView
    headerView?.setNeedsLayout()
    headerView?.layoutIfNeeded()
    let height = headerView?.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
    var frame = headerView?.frame
    frame?.size.height = height ?? 0.0
    headerView?.frame = frame ?? CGRect.init()
    tableHeaderView = headerView
  }
  
  func registerXIB(_ nibName: String) {
    register(UINib.init(nibName: nibName, bundle: nil), forCellReuseIdentifier: nibName)
  }
  
  func registerXIBForHeaderFooter(_ nibName: String) {
    register(UINib.init(nibName: nibName, bundle: nil), forHeaderFooterViewReuseIdentifier: nibName)
  }
}

extension UICollectionView {
  func registerXIB(_ nibName: String) {
    register(UINib.init(nibName: nibName, bundle: nil), forCellWithReuseIdentifier: nibName)
  }
}

public extension NSObject{
    class var name: String{
    return NSStringFromClass(self).components(separatedBy: ".").last!
  }
  
    var name: String{
    return NSStringFromClass(type(of: self)).components(separatedBy: ".").last!
  }
}

extension UIScrollView {
  
  var isAtTop: Bool {
    return contentOffset.y <= verticalOffsetForTop
  }
  
  var isAtBottom: Bool {
    return contentOffset.y >= verticalOffsetForBottom
  }
  
  var verticalOffsetForTop: CGFloat {
    let topInset = contentInset.top
    return -topInset
  }
  
  var verticalOffsetForBottom: CGFloat {
    let scrollViewHeight = bounds.height
    let scrollContentSizeHeight = contentSize.height
    let bottomInset = contentInset.bottom
    let scrollViewBottomOffset = scrollContentSizeHeight + bottomInset - scrollViewHeight
    return scrollViewBottomOffset
  }
  
}
