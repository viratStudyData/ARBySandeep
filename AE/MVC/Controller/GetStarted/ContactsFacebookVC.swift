//
//  ContactsFacebookVC.swift
//  AE
//
//  Created by MAC_MINI_6 on 04/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class ContactsFacebookVC: BaseVC {

  @IBOutlet weak var tableView: UITableView! {
    didSet {
      tableView.registerXIB(UserInviteTVCell.name)
      tableView.registerXIB(FollowBusinessTVCell.name)
      tableView.registerXIBForHeaderFooter(InviteTVHeader.name)
    }
  }
  @IBOutlet weak var tfSearch: UITextField!
  @IBOutlet weak var lblPlaceholder: UILabel!
  @IBOutlet weak var indicator: UIActivityIndicatorView!
  @IBOutlet weak var btnRetrySettings: UIButton!
  
  var vcType: InviteFriendTab = .Contacts
  var itemInfo: IndicatorInfo = IndicatorInfo(title: "Your tab title here")
  private var dataSource: TableDataSource<HeaderFooterData>?
  private var contacts = [ContactNumber]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableViewInit()
    
    switch vcType {
    case .Contacts:
      ContactManager.shared.checkAutorization({ [weak self] (granted) in
        self?.handleIndicators(/granted ? .GettingContacts : .ContactsDenied)
      }) { [weak self] (contacts) in
        self?.contacts = contacts ?? []
        self?.parseNumbers()
      }
    case .Facebook:
      handleIndicators(.NoFBSignup)
    }
  }
  
  //MARK:- Retry and settings actions
  @IBAction func btnRetrySettingsAction(_ sender: UIButton) {
    if /sender.title(for: .normal) == VCLiteral.SETTINGS.localized {
      phoneServices.openSettings()
      return
    }
    switch vcType {
    case .Contacts:
      parseNumbers()
    case .Facebook:
      break
    }
  }
  
}

//MARK:- VCFuncs
extension ContactsFacebookVC {
  func handleIndicators(_ type: InviteFriendsLoad) {
    lblPlaceholder.isHidden = type.showMessage
    lblPlaceholder.text = /type.message
    if type.showLoader {
      indicator.startAnimating()
    } else {
      indicator.stopAnimating()
    }
    btnRetrySettings.isHidden = type.showButton
    btnRetrySettings.setTitle(/type.btnTitle, for: .normal)
  }
  
  func parseNumbers() {
    handleIndicators(.SyncingContacts)
    let phoneNumbers = contacts.map({$0.number ?? ContactSynced()})
    EP_Login.syncContacts(contacts: phoneNumbers).request(success: { [weak self] (response) in
      let responseData = (response as? [ContactSynced]) ?? []
      self?.handleIndicators(responseData.count == 0 ? .NoContacts : .DataLoaded)
      for (index, item) in responseData.enumerated() {
        self?.contacts[index].number = item
      }
      self?.dataSource?.updateAndReload(for: .SingleListing(items: self?.contacts ?? []), .FullReload)
    }) { [weak self] (error) in
      self?.handleIndicators(.CustomError(error: /error))
    }
  }
  
  func tableViewInit() {
    dataSource = TableDataSource<HeaderFooterData>.init(.SingleListing(items: contacts, identifier: UserInviteTVCell.name, height: UITableView.automaticDimension), tableView)
    dataSource?.configureCell = { (cell, item, indexPath, property) in
      (cell as? UserInviteTVCell)?.item = item
    }
  }
}



//MARK:- XLPagerTabStrip Delegate
extension ContactsFacebookVC: IndicatorInfoProvider {
  func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
    return itemInfo
  }
}
