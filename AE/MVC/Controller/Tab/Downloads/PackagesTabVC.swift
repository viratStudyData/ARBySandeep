//
//  PackagesTabVC.swift
//  AE
//
//  Created by MAC_MINI_6 on 11/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class PackagesTabVC: UIViewController {
  
  @IBOutlet weak var tableView: UITableView! {
    didSet {
      tableView.registerXIB(PackageCell.identfier)
    }
  }
  @IBOutlet weak var noDataView: UIView!
  
  var vcType: DownloadsTab = .Package
  var itemInfo: IndicatorInfo = IndicatorInfo(title: "Your tab title here")
  private var dataSource: TableDataSource<HeaderFooterData>?
  private var items: [Package]?
  
  override func viewDidLoad() {
    super.viewDidLoad()
//    tableView.contentInset.top = 16
//    items = DownloadPreference.shared.getPackages()
//    dataSource = TableDataSource<HeaderFooterData>.init(.SingleListing(items: items ?? [], identifier: PackageCell.identfier, height: TableHeight.PackageCell), tableView)
//
//    dataSource?.configureCell = { (cell, item, indexPath, property) in
//      (cell as? PackageCell)?.downloadedItem = item as? Package
//    }
//
//    dataSource?.didSelectRow = { [weak self] (indexPath, item, property) in
//      let destVC = StoryboardScene.Other.PackageDetailVC.instantiate()
//      destVC.package = item as? Package
//      destVC.isDownloadedDetail = true
//      destVC.business = (item as? Package)?.businessId
//      self?.pushVC(destVC)
//    }
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(true)
//    items = DownloadPreference.shared.getPackages()
//    noDataView.isHidden = /items?.count != 0
//    dataSource?.updateAndReload(for: .SingleListing(items: items ?? []), .FullReload)
  }
}

//MARK:- XLPagerTabStrip Delegate
extension PackagesTabVC: IndicatorInfoProvider {
  func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
    return itemInfo
  }
}
