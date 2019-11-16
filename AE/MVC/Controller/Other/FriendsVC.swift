//
//  FriendsVC.swift
//  AE
//
//  Created by MAC_MINI_6 on 29/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

class FriendsVC: BaseVC {
  @IBOutlet weak var lblTitle: UILabel!
  @IBOutlet weak var navBar: UIView!
  @IBOutlet weak var titleTopConstraint: NSLayoutConstraint! // 44 or 0
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var tfSearch: UITextField!
  @IBOutlet weak var lblNoData: UILabel!
  
  private var dataSource: TableDataSource<HeaderFooterData>?
  private var items: [UserData]?
  private var pageNo = 0
  let semaphore = DispatchSemaphore(value: 1)

  override func viewDidLoad() {
    super.viewDidLoad()
    tableViewinit()
    tfSearch.delegate = self
    tfSearch.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
  }
  
  @IBAction func btnBackAction(_ sender: UIButton) {
    popVC()
  }
  
}

//MARK:- VCFuncs
extension FriendsVC {

  private func tableViewinit() {
    dataSource = TableDataSource<HeaderFooterData>(TableType.SingleListing(items: items ?? [], identifier: FriendCell.identfier, height: UITableView.automaticDimension), tableView, true)
    
    dataSource?.configureCell = { (cell, item, indexPath, property) in
      (cell as? FriendCell)?.item = item
      (cell as? FriendCell)?.friendRemoved = { [weak self] (friend) in
        self?.deleteFriend(friend, indexPath)
      }
    }
    
    dataSource?.scrollDirection = { [weak self] (direction) in
      if direction == .Down {
        self?.navBar.isHidden = true
      }
      self?.navigationBarAnimationHandling(direction: direction)
    }
    
    dataSource?.addInfiniteScrolling = { [weak self] in
      self?.pageNo = /self?.pageNo + 1
      self?.getFriendsAPI()
    }
    
    dataSource?.addPullToRefresh = { [weak self] in
      self?.tfSearch.text = nil
      self?.tfSearch.resignFirstResponder()
      self?.pageNo = 0
      self?.items = []
      self?.dataSource?.updateAndReload(for: .SingleListing(items: self?.items ?? []), .FullReload)
      self?.getFriendsAPI()
    }
    
    dataSource?.refreshProgrammatically()
    
  }
  
  private func deleteFriend(_ friend: UserData?, _ indexPath: IndexPath) {
    items?.removeAll(where: { $0 == friend })
    dataSource?.updateAndReload(for: UpdateType.SingleListing(items: items ?? []), ReloadType.DeleteRowsAt(indexPaths: [indexPath], animation: .right))
    lblNoData.isHidden = /items?.count != 0
  }
  
  private func getFriendsAPI() {
    DispatchQueue.main.async { [weak self] in
      self?.semaphore.wait()
      EP_Other.userFriends(pageNo: String(/self?.pageNo), keyword: self?.tfSearch.text).request(success: { [weak self] (response) in
        let newItems = (response as? [UserData]) ?? []
        self?.dataSource?.stopInfiniteLoading(newItems.count == 0 ? .NoContentAnyMore : .FinishLoading)
        self?.items = (self?.items ?? []) + newItems
        self?.dataSource?.updateAndReload(for: .SingleListing(items: self?.items ?? []), .FullReload)
        self?.lblNoData.isHidden = /self?.items?.count != 0
      }) { [weak self] (error) in
        self?.dataSource?.stopInfiniteLoading(.FinishLoading)
        if /self?.pageNo > 0 {
          self?.pageNo = /self?.pageNo - 1
        }
      }
      self?.semaphore.signal()
    }
  }
  
  //MARK:- Handling Animation for navigation bar
  private func navigationBarAnimationHandling(direction: ScrollDirection) {
    titleTopConstraint.constant = direction == .Up ? 0 : 44
    UIView.transition(with: lblTitle, duration: 0.2, options: .curveLinear, animations: {
      self.lblTitle.textAlignment = direction == .Up ? .center : .left
    })
    UIView.animate(withDuration: 0.2, animations: { [weak self] in
      self?.lblTitle?.transform = direction == .Up ? CGAffineTransform.init(scaleX: 0.6, y: 0.6) : CGAffineTransform.identity
      self?.view.layoutSubviews()
    })
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
      self?.navBar.isHidden = (direction == .Down)
    }
  }
}

extension FriendsVC: UITextFieldDelegate {
  @objc func textFieldEditingChanged(_ textField: UITextField) {
    pageNo = 0
    items = []
    dataSource?.updateAndReload(for: .SingleListing(items: items ?? []), .FullReload)
    getFriendsAPI()
  }
  
  internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    pageNo = 0
    items = []
    dataSource?.updateAndReload(for: .SingleListing(items: items ?? []), .FullReload)
    getFriendsAPI()
    textField.resignFirstResponder()
    return true
  }
}
