//
//  DownloadsVC.swift
//  AE
//
//  Created by MAC_MINI_6 on 11/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

class DownloadsVC: BaseVC {
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var noDataView: UIView!
  
  private var dataSource: TableDataSource<HeaderFooterData>?
  private var items: [Object]?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.tableFooterView = UIView()
    dataSource = TableDataSource<HeaderFooterData>.init(.SingleListing(items: items ?? [], identifier: DownloadedObjectCell.identfier, height: TableHeight.DownloadedObject), tableView)
    
    dataSource?.configureCell = { (cell, item, indexPath, property) in
      (cell as? DownloadedObjectCell)?.item = item
      (cell as? DownloadedObjectCell)?.btnOptionsTapped = { [weak self] in
        self?.deleteItemAt(index: indexPath.row)
      }
    }
    
    dataSource?.didSelectRow = { [weak self] (indexPath, item, property) in
      self?.tapObjectAction(with: item as? Object)
    }
    
//    let fm = FileManager.default
//    let path = MZUtility.baseFilePath
//
//    do {
//      let items = try fm.contentsOfDirectory(atPath: path)
//
//      for item in items {
//        print("Found \(item)")
//      }
//    } catch {
//      // failed to read directory – bad permissions, perhaps?
//    }
    
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(true)
    items = DownloadPreference.shared.getCompletedDownloads()
    noDataView.isHidden = /items?.count != 0
    dataSource?.updateAndReload(for: .SingleListing(items: items ?? []), .FullReload)
  }
}
//MARK:- VCFuncs
extension DownloadsVC {
  func deleteItemAt(index: Int) {
    actionSheet(for: [VCLiteral.DELETE.localized], title: String.init(format: VCLiteral.DELETE_OBJECT_ALERT.localized, /items?[index].name) , message: nil) { [weak self] (selectedString) in
      DownloadPreference.shared.delete(obj: self?.items?[index])
      self?.items?.remove(at: index)
      self?.dataSource?.updateAndReload(for: .SingleListing(items: self?.items ?? []), .DeleteRowsAt(indexPaths: [IndexPath(row: index, section: 0) ], animation: .right))
    }
  }
}

