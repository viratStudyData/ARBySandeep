//
//  ShareWithVC.swift
//  AE
//
//  Created by MAC_MINI_6 on 22/06/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

class ShareWithVC: BaseVC {
  
  @IBOutlet weak var lblTitle: UILabel!
  @IBOutlet weak var navBar: UIView!
  @IBOutlet weak var titleTopConstraint: NSLayoutConstraint! // 44 or 0
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var tfSearch: UITextField!
  
  private var dataSource: TableDataSource<HeaderFooterData>?
  private var items: [UserData]?
  private var pageNo = 0
  var shareItem: ShareItemType?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableViewinit()
    saveAccessory.didTap = { [weak self] in
      if /self?.items?.filter({ /$0.isSelected }).count > 0 {
        self?.uploadItemAPI()
      } else {
        //Show Error Please select a user first
      }
    }
  }
  

  
  override var inputAccessoryView: UIView? {
    saveAccessory.setButtonTitle(VCLiteral.SEND.localized)
    return saveAccessory
  }
  
  override var canBecomeFirstResponder: Bool {
    return true
  }
  
  @IBAction func btnAction(_ sender: UIButton) {
    switch sender.tag {
    case 0: //Back Action
      popVC()
    case 1: //Select ALL
      items?.forEach { $0.isSelected = true }
      dataSource?.updateAndReload(for: .SingleListing(items: items ?? []), .FullReload)
    default:
      break
    }
  }
  
}

//MARK:- VCFuncs
extension ShareWithVC {
  
  private func uploadItemAPI() {
    saveAccessory.setButtonTitle(VCLiteral.UPLOADING.localized)
    saveAccessory.startButtonAnimation()
    view.isUserInteractionEnabled = false
//    saveAccessory.btn.isUserInteractionEnabled = false
    EP_Other.uploadItem(item: shareItem).request(success: { [weak self] (response) in
      let url = response as? ImageURL
      self?.sendMessageSocket(url)
    }) { [weak self] (error) in
        self?.view.isUserInteractionEnabled = true
        self?.saveAccessory.stopButtonAnimation()
        self?.saveAccessory.setButtonTitle(VCLiteral.RETRY.localized)
    }
  }
  
  private func sendMessageSocket(_ url: ImageURL?) {
    let selectedUsers = items?.filter({ /$0.isSelected })
    let ids = selectedUsers?.map({ /$0._id })
    
    let message = SendMessage.init(ids: ids, _fileUrl: url, _messageType: shareItem?.messageType)
    
    SocketIOManager.shared.sendMessage(model: message, nameSpace: .AppActive) { [weak self] in
        //Message Sent successfully
        self?.view.isUserInteractionEnabled = true
        self?.saveAccessory.stopButtonAnimation()
        self?.saveAccessory.setButtonTitle(VCLiteral.SEND.localized)
        self?.popVCs(viewsToPop: 3)
    }
  }
  
  private func tableViewinit() {
    dataSource = TableDataSource<HeaderFooterData>(TableType.SingleListing(items: items ?? [], identifier: UserCheckUncheckCell.identfier, height: UITableView.automaticDimension), tableView, true)
    
    dataSource?.configureCell = { (cell, item, indexPath, property) in
      (cell as? UserCheckUncheckCell)?.item = item
    }
    
    dataSource?.didSelectRow = { [weak self] (indexPath, item, property) in
      self?.items?[indexPath.row].isSelected = !(/self?.items?[indexPath.row].isSelected)
      self?.dataSource?.updateAndReload(for: .SingleListing(items: self?.items ?? []), .Reload(indexPaths: [indexPath], animation: .automatic))
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
      self?.pageNo = 0
      self?.items = []
      self?.dataSource?.updateAndReload(for: .SingleListing(items: self?.items ?? []), .FullReload)
      self?.getFriendsAPI()
    }
    
    dataSource?.refreshProgrammatically()
    
  }
  
  private func getFriendsAPI() {
    EP_Other.userFriends(pageNo: String(pageNo), keyword: nil).request(success: { [weak self] (response) in
      let newItems = (response as? [UserData]) ?? []
      self?.dataSource?.stopInfiniteLoading(newItems.count == 0 ? .NoContentAnyMore : .FinishLoading)
      self?.items = (self?.items ?? []) + newItems
      self?.dataSource?.updateAndReload(for: .SingleListing(items: self?.items ?? []), .FullReload)
    }) { [weak self] (error) in
      self?.dataSource?.stopInfiniteLoading(.FinishLoading)
      if /self?.pageNo > 0 {
        self?.pageNo = /self?.pageNo - 1
      }
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
