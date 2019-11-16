//
//  SKRefreshControl.swift
//  AE
//
//  Created by MAC_MINI_6 on 27/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

extension UIScrollView {
  /// A helper method to add SKRefreshControl instace to self(UIScrollView instance).
  func addSKPullToRefresh(didStartRefreshing: @escaping () -> () ) {
    let skControl = SKRefreshControl.init(self)
    skControl.pulled = {
      didStartRefreshing()
    }
  }
  
  func stopSKRefresh() {
    refreshControl?.endRefreshing()
  }
}

public class SKRefreshControl: UIRefreshControl {
  
  /// A block is called when user triggers pull to refresh in the UIScrollView.
  typealias Pulled = () -> ()
  
  var pulled: Pulled?
  
  init(_ scrollView: UIScrollView) {
    super.init()
    if #available(iOS 10.0, *) {
      scrollView.refreshControl = self
    } else {
      if scrollView.isKind(of: UITableView.self) {
        (scrollView as! UITableView).backgroundView = self
      } else if scrollView.isKind(of: UICollectionView.self) {
        (scrollView as! UICollectionView).backgroundView = self
      }
    }
    self.addTarget(self, action: #selector(refreshControlPulled), for: .valueChanged)
  }
  
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  @objc func refreshControlPulled() {
    pulled?()
  }
}
