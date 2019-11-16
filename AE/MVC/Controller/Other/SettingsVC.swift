//
//  SettingsVC.swift
//  AE
//
//  Created by MAC_MINI_6 on 17/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

class SettingsVC: BaseVC {
  
  @IBOutlet weak var btnBack: UIButton!
  @IBOutlet weak var navBar: UIView!
  @IBOutlet weak var tableView: UITableView! {
    didSet {
      tableView.registerXIBForHeaderFooter(ShowLocationHeader.identfier)
    }
  }
  @IBOutlet weak var titleTopConstraint: NSLayoutConstraint! // 44 or 0
  
  private var dataSource: TableDataSource<HeaderFooterData>?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.contentInset.top = 16.0
    dataSource = TableDataSource<HeaderFooterData>.init(.MultipleSection(items: HeaderFooterData.getSettingsData()), tableView)
    
    dataSource?.configureHeaderFooter = { [weak self] (section, item, view, isHeader) in
      (view as? ShowLocationHeader)?.item = item
      (view as? ShowLocationHeader)?.didChangeSwitch = { (isOn) in
        self?.updateLoationSettingAPI(status: isOn ? .CONTACTS_ONLY : .NONE)
      }
    }
    
    dataSource?.configureCell = { (cell, item, indexPath, property) in
      switch /property?.headerIdentifier {
      case ShowLocationHeader.identfier:
        (cell as? SettingCellRegular)?.item = item
      default:
        (cell as? SettingCellBold)?.item = item
      }
    }
    
    dataSource?.didSelectRow = { [weak self] (indexPath, item, _) in
      self?.handleCellTap((item as? Setting)?.title ?? .SETTING_EDIT_PROFILE)
    }
    
    
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(true)
  }
  
  func handleCellTap(_ vcLiteral: VCLiteral) {
    switch vcLiteral {
    case .SETTING_CONTACTS_ONLY:
      updateLoationSettingAPI(status: .CONTACTS_ONLY)
    case .SETTING_EVERYONE:
      updateLoationSettingAPI(status: .EVERYONE)
    case .SETTING_EDIT_PROFILE:
      let destVC = StoryboardScene.Other.EditProfileVC.instantiate()
      pushVC(destVC)
    case .SETTING_CHANGE_PASSWORD:
      let destVC = StoryboardScene.GetStarted.ChangePSWVC.instantiate()
      pushVC(destVC)
    case .SETTING_CONTACT_US:
      let destVC = StoryboardScene.Other.ContactUsVC.instantiate()
      pushVC(destVC)
    case .SETTING_ABOUT:
      let destVC = StoryboardScene.Other.AboutUsVC.instantiate()
      pushVC(destVC)
    default: break
    }
  }
  
  private func updateLoationSettingAPI(status: ShowLocationType) {
    EP_Login.updateLocation(type: status).request(success: { [weak self] (response) in
      self?.changeLocationShare(status)
    })
  }
  
  private func changeLocationShare(_ type: ShowLocationType) {
    let tempPreference = UserPreference.shared.data
    tempPreference?.showLocation = type
    UserPreference.shared.data = tempPreference
    dataSource?.updateAndReload(for: .MultipleSection(items: HeaderFooterData.getSettingsData()), ReloadType.ReloadSectionAt(indexSet: IndexSet(integer: 0), animation: .automatic))
  }
  
  @IBAction func btnBackAction(_ sender: UIButton) {
    popVC()
  }
  
}
