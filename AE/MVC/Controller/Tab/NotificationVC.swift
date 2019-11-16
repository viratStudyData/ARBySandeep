//
//  NotificationVC.swift
//  AE
//
//  Created by MAC_MINI_6 on 13/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

enum NotificationStatus: String {
  case READ = "READ"
  case UNREAD = "UNREAD"
  case CLEAR = "CLEAR"
}

class NotificationVC: BaseVC {

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var lblNoData: UILabel!
  @IBOutlet weak var btnClear: UIButton!
  
  private var dataSource: TableDataSource<HeaderFooterData>?
  private var pageNo = 0
  private var items: [Notification]?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if !CommonFuncs.shared.isUserLoggedIn(showPopUp: true, canBeCancelled: false) {
      return
    }
    tableViewInit()
  }
  
  @IBAction func btnClearNotificationAction(_ sender: UIButton) {
    alertBoxOKCancel(title: "", message: VCLiteral.CLEAR_NOTIFICATIONS_ALERT.localized, tapped: { [weak self] in
      //Hit Clear api
      self?.clearNotificationAPI()
    }) {
      
    }
  }
  
}

//MARK:- VCFuncs
extension NotificationVC {
  
  private func clearNotificationAPI() {
    EP_Other.readUnreadNotification(id: nil, status: .CLEAR).request(success: { [weak self] (response) in
      self?.items = []
      self?.dataSource?.updateAndReload(for: .SingleListing(items: self?.items ?? []), .FullReload)
      self?.lblNoData.isHidden = /self?.items?.count != 0
      self?.btnClear.isHidden = /self?.items?.count == 0
    }) { (_) in
      
    }
  }
  
  func tableViewInit() {
    
    tableView.contentInset.top = 16.0

    dataSource = TableDataSource<HeaderFooterData>.init(.SingleListing(items: items ?? [], identifier: NotificationCell.identfier, height: UITableView.automaticDimension), tableView, true)
    
    dataSource?.configureCell = { (cell, item, indexPath, property) in
      (cell as? NotificationCell)?.item = item
    }
    
    dataSource?.addPullToRefresh = { [weak self] in
      self?.pageNo = 0
      self?.items = []
      self?.dataSource?.updateAndReload(for: .SingleListing(items: self?.items ?? []), .FullReload)
      self?.getNotificationsAPI()
    }

    dataSource?.didSelectRow = { [weak self] (indexPath, item, property) in
      let notification = (item as? Notification)
      switch notification?.notificationType ?? .FRIEND_REQUEST {
      case .FRIEND_REQUEST:
        DispatchQueue.main.async {
          self?.friendRequestOptions(notification)
        }
      default:
        break
      }
    }
    
    dataSource?.addInfiniteScrolling = { [weak self] in
      self?.pageNo = /self?.pageNo + 1
      self?.getNotificationsAPI()
    }
    
    dataSource?.refreshProgrammatically()
  }
  
  
  func friendRequestOptions(_ notification: Notification?) {
    actionSheet(for: [VCLiteral.FRIEND_REQUEST_ACCEPT.localized,
                            VCLiteral.FRIEND_REQUEST_REJECT.localized],
                      title: VCLiteral.FRIEND_REQUEST_TITLE.localized, message: String(format: VCLiteral.FRIEND_REQUEST_MESSAGE.localized, /notification?.userId?.name) ,
                      tapped: { [weak self] (tappedString) in
                        switch tappedString {
                        case VCLiteral.FRIEND_REQUEST_ACCEPT.localized:
                          self?.acceptRejectRequest(action: .ACCEPT, id: /notification?.requestId, noti: notification)
                        case VCLiteral.FRIEND_REQUEST_REJECT.localized:
                          self?.acceptRejectRequest(action: .REJECT, id: /notification?.requestId, noti: notification)
                        default: break
                        }
    })
  }
  
  func acceptRejectRequest(action: RequestAction, id: String, noti: Notification?) {
    EP_Other.acceptRejectRequest(id: id, action: action).request(success: { [weak self] (response) in
      switch action {
      case .ACCEPT:
        Toast.shared.showAlert(type: .success, message: String(format: VCLiteral.FRIEND_REQUEST_SUCCESS.localized, /noti?.userId?.name) )
      case .REJECT:
        break
      }
      guard let index: Int = self?.items?.firstIndex(where: {/$0._id == /noti?._id}) else { return }
      self?.items?.remove(at: index)
      self?.dataSource?.updateAndReload(for: .SingleListing(items: self?.items ?? []), .DeleteRowsAt(indexPaths: [IndexPath(row: index, section: 0) ], animation: .right))
      self?.lblNoData.isHidden = /self?.items?.count != 0
      self?.btnClear.isHidden = /self?.items?.count == 0

    }) { (error) in
      
    }
  }
  
  func getNotificationsAPI() {
    EP_Other.notifications(pageNo: String(pageNo)).request(success: { [weak self] (response) in
      let newItems = (response as? NotificationData)?.data ?? []
      self?.dataSource?.stopInfiniteLoading(newItems.count == 0 ? .NoContentAnyMore : .FinishLoading)
      self?.items = (self?.items ?? []) + newItems
      self?.dataSource?.updateAndReload(for: .SingleListing(items: self?.items ?? []), .FullReload)
      self?.lblNoData.isHidden = /self?.items?.count != 0
      self?.btnClear.isHidden = /self?.items?.count == 0

    }) { [weak self] (error) in
      if /self?.pageNo != 0 {
        self?.pageNo = /self?.pageNo - 1
      }
      self?.dataSource?.stopInfiniteLoading(.FinishLoading)
    }
  }
  
}
