//
//  ProfileVC.swift
//  AE
//
//  Created by MAC_MINI_6 on 12/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit
import MXParallaxHeader

class ProfileVC: BaseVC {
  @IBOutlet weak var tableView: UITableView! {
    didSet {
      tableView.registerXIBForHeaderFooter(LineHeaderFooter.identfier)
    }
  }
  @IBOutlet weak var imgProfile: UIImageView!
  @IBOutlet weak var lblName: UILabel!
  @IBOutlet weak var lblEmail: UILabel!
  @IBOutlet weak var lblPhone: UILabel!
  @IBOutlet var headerView: UIView!
  @IBOutlet weak var profileWidth: NSLayoutConstraint!
  @IBOutlet weak var constraintNameTop: NSLayoutConstraint!
  @IBOutlet weak var constraintEmailTop: NSLayoutConstraint!
  @IBOutlet weak var constraintPhoneTop: NSLayoutConstraint!
  @IBOutlet weak var imgBackView: UIView!
  @IBOutlet weak var btnEdit: UIButton!
  
  private var dataSource: TableDataSource<HeaderFooterData>?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    parralaxHeaderSetup()
    tableViewSetup()
    initialInfoSetup()
    
    EP_Other.appDefaults.request(success: { (response) in
      UserPreference.shared.appDefaults = response as? AppDefault
    })
  }
  
  
  @IBAction func btnAction(_ sender: UIButton) {
    switch sender.tag {
    case 0: // Back Action
      popVC()
    case 1: // Edit Profile Action
      let destVC = StoryboardScene.Other.EditProfileVC.instantiate()
      pushVC(destVC)
      

    default:
      break
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(true)
    //    initialInfoSetup()
    
    EP_Other.getProfile.request(success: { [weak self] (response) in
      let tempData = UserPreference.shared.data
      //      tempData?.imageUrl = (response as? UserData)?.imageUrl
      tempData?.messageCount = /(response as? UserData)?.messageCount
      tempData?.friendsCount = /(response as? UserData)?.friendsCount
      UserPreference.shared.data = tempData
      self?.initialInfoSetup()
    })
  }
}

//MARK:- VCFuncs
extension ProfileVC {
  //MARK:- Parralax Header setup
  private func parralaxHeaderSetup() {
    let widthOfProfile = ScreenSize.SCREEN_WIDTH * 0.4
    imgProfile.cornerRadius = widthOfProfile / 2
    imgBackView.cornerRadius = widthOfProfile / 2
    profileWidth.constant = widthOfProfile
    tableView.parallaxHeader.view = headerView
    tableView.parallaxHeader.height = widthOfProfile + 16 + 128
    tableView.parallaxHeader.minimumHeight = 0
    tableView.parallaxHeader.delegate = self
  }
  
  private func initialInfoSetup() {
    let user = UserPreference.shared.data
    lblName.text = /user?.name
    lblEmail.text = /user?.email
    
    imgProfile.setImageKF(user?.imageUrl?.thumbnail, placeHolder: #imageLiteral(resourceName: "ic_profile_placeholder"))
    
    
    if /user?.phoneNumber?.phoneNo != "" {
      lblPhone.text = "+\(/user?.phoneNumber?.countryCode)-\(/user?.phoneNumber?.phoneNo)"
    } else {
      lblPhone.text = ""
    }
    dataSource?.updateAndReload(for: .MultipleSection(items: HeaderFooterData.getProfileData()), .FullReload)
  }
  
  //MARK:- TableView Setup
  private func tableViewSetup() {
    dataSource = TableDataSource<HeaderFooterData>.init(.MultipleSection(items: HeaderFooterData.getProfileData()), tableView)
    
    dataSource?.configureCell = { (cell, item, indexPath, property) in
      (cell as? SettingCell)?.item = item
    }
    
    dataSource?.didSelectRow = { [weak self] (indexPath, item, _) in
      switch (item as? ProfileCellData)?.title ?? .PROFILE_CELL_TITLE_FOLLOWING {
      case .PROFILE_CELL_TITLE_FOLLOWING:
        let destVC = StoryboardScene.Other.FollowingVC.instantiate()
        self?.pushVC(destVC)
      case .PROFILE_CELL_TITLE_FRIENDS:
        let destVC = StoryboardScene.Other.FriendsVC.instantiate()
        self?.pushVC(destVC)
      case .PROFILE_CELL_TITLE_MESSAGES:
        let destVC = StoryboardScene.Other.MessagesVC.instantiate()
        self?.pushVC(destVC)
      case .PROFILE_CELL_TITLE_INVITEFRIENDS:
        let destVC = StoryboardScene.GetStarted.InviteFriendsVC.instantiate()
        destVC.navigatedFrom = .FromProfile
        self?.pushVC(destVC)
      case .PROFILE_CELL_TITLE_SETTINGS:
        let destVC = StoryboardScene.Other.SettingsVC.instantiate()
        self?.pushVC(destVC)
      case .PROFILE_CELL_TITLE_SIGNOUT:
        DispatchQueue.main.async {
          self?.logoutOutAlert()
        }
      default:
        break
      }
    }
  }
  
  func logoutOutAlert() {
    alertBoxOKCancel(title: nil, message: VCLiteral.LOGOUT_ALERT.localized, tapped: { [weak self] in
      self?.logoutAPI()
      }, cancelTapped: nil)
  }
  
  func logoutAPI() {
    EP_Login.logout.request(success: { (response) in
      CommonFuncs.shared.storyboardReInstantiateFor(.Logout)
    })
  }
}

//MARK:- MXParralaxHeader Delegate
extension ProfileVC: MXParallaxHeaderDelegate {
  internal func parallaxHeaderDidScroll(_ parallaxHeader: MXParallaxHeader) {
    let widthOfProfile = (ScreenSize.SCREEN_WIDTH * 0.4) * parallaxHeader.progress
    imgProfile.cornerRadius = widthOfProfile / 2
    imgBackView.cornerRadius = widthOfProfile / 2
    profileWidth.constant = widthOfProfile
    btnEdit.cornerRadius = (widthOfProfile * 0.25) / 2
    constraintNameTop.constant = 24 * parallaxHeader.progress
    constraintEmailTop.constant = 8 * parallaxHeader.progress
    constraintPhoneTop.constant = 8 * parallaxHeader.progress
    let transformValue = CGAffineTransform.init(scaleX: parallaxHeader.progress, y: parallaxHeader.progress)
    lblEmail.transform = transformValue
    lblName.transform = transformValue
    lblPhone.transform = transformValue
    view.layoutSubviews()
  }
}
