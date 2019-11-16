//
//  SearchVC.swift
//  AE
//
//  Created by MAC_MINI_6 on 24/05/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

class SearchVC: BaseVC {

  @IBOutlet weak var tfSearch: UITextField!
  @IBOutlet weak var tableView: UITableView! {
    didSet {
      tableView.registerXIBForHeaderFooter(SearchSection.identfier)
    }
  }
  
  private var apiResponse: MapData? {
    didSet {
      dataSource?.updateAndReload(for: .MultipleSection(items: HeaderFooterData.getSearchResults(apiResponse)), .FullReload)
    }
  }
  private var dataSource: TableDataSource<HeaderFooterData>?
  let semaphore = DispatchSemaphore(value: 1)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupTable()
    tfSearch.becomeFirstResponder()
    tfSearch.delegate = self
    tfSearch.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
    searchAPIHit()
  }
  
  @IBAction func btnBackAction(_ sender: UIButton) {
    popVC()
  }
}

//MARK:- VCFuncs
extension SearchVC {
  private func setupTable() {
    dataSource = TableDataSource<HeaderFooterData>(.MultipleSection(items: HeaderFooterData.getSearchResults(apiResponse)), tableView)
    
    dataSource?.configureHeaderFooter = { (section, item, view, isHeader) in
      (view as? SearchSection)?.item = item
    }
    
    dataSource?.configureCell = { (cell, item, indexPath, property) in
      switch /property?.cellIdentifier {
      case SearchBusinessCell.identfier:
        (cell as? SearchBusinessCell)?.item = item
      case SearchUserCell.identfier:
        (cell as? SearchUserCell)?.item = item
      default:
        break
      }
    }
    
    dataSource?.didSelectRow = { [weak self] (indexPath, item, _) in
      if let business = item as? Business {
        let destVC = StoryboardScene.Other.BusinessDetailVC.instantiate()
        destVC.business = business
        self?.pushVC(destVC)
      }
    }
    
  }
  
  private func searchAPIHit() {
    DispatchQueue.main.async { [weak self] in
      self?.semaphore.wait()
      EP_Other.homeSearch(pageNo: "0", search: self?.tfSearch.text, flag: MapFlag.ALL).request(success: { [weak self] (response) in
        
        self?.apiResponse = (response as? MapData)
        
      }) { (error) in
        
      }
      self?.semaphore.signal()
    }
  }
}

//MARK:- UITextFieldDelegate
extension SearchVC: UITextFieldDelegate {
  internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    searchAPIHit()
    textField.resignFirstResponder()
    return true
  }
  
  func textFieldShouldClear(_ textField: UITextField) -> Bool {
    searchAPIHit()
    return true
  }
  
  @objc func textFieldEditingChanged(_ textField: UITextField) {
    searchAPIHit()
  }
}
