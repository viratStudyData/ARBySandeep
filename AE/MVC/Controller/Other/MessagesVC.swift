//
//  MessagesVC.swift
//  AE
//
//  Created by MAC_MINI_6 on 29/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

class MessagesVC: BaseVC {
  
  @IBOutlet weak var lblTitle: UILabel!
  @IBOutlet weak var navBar: UIView!
  @IBOutlet weak var titleTopConstraint: NSLayoutConstraint! // 44 or 0
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var tableViewTop: NSLayoutConstraint! // 16 or 0
  @IBOutlet weak var lblNoData: UILabel!
  
  private var dataSource: TableDataSource<HeaderFooterData>?
  private var items: [Message]?
  private var pageNo = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableViewinit()
  }
  
  @IBAction func btnBackAction(_ sender: UIButton) {
    popVC()
  }
  
}

//MARK:- VCFuncs
extension MessagesVC {
  
  private func tableViewinit() {
    dataSource = TableDataSource<HeaderFooterData>(TableType.SingleListing(items: items ?? [], identifier: MessageCell.identfier, height: UITableView.automaticDimension), tableView, true)
    
    dataSource?.configureCell = { (cell, item, indexPath, property) in
      (cell as? MessageCell)?.item = item
    }
    
    dataSource?.scrollDirection = { [weak self] (direction) in
      if direction == .Down {
        self?.navBar.isHidden = true
      }
      self?.navigationBarAnimationHandling(direction: direction)
    }
    
    dataSource?.addInfiniteScrolling = { [weak self] in
      self?.pageNo = /self?.pageNo + 1
      self?.getMessagesAPI()
    }
    
    dataSource?.addPullToRefresh = { [weak self] in
      self?.pageNo = 0
      self?.items = []
      self?.dataSource?.updateAndReload(for: .SingleListing(items: self?.items ?? []), .FullReload)
      self?.getMessagesAPI()
    }
    
    dataSource?.refreshProgrammatically()
  }
  
  func getMessagesAPI() {
    EP_Other.messageListing(pageNo: String(pageNo)).request(success: { [weak self] (response) in
      let newItems = (response as? [Message]) ?? []
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
  }
  
  //MARK:- Handling Animation for navigation bar
  private func navigationBarAnimationHandling(direction: ScrollDirection) {
    tableViewTop.constant = direction == .Up ? 0 : 16.0
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
