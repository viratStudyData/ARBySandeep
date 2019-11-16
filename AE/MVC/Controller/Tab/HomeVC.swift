//
//  HomeVC.swift
//  AE
//
//  Created by MAC_MINI_6 on 08/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit
import CoreLocation

class HomeVC: BaseVC {

  @IBOutlet weak var tableView: UITableView! {
    didSet {
      tableView.registerXIBForHeaderFooter(HomeSection.identfier)
      tableView.registerXIB(HorizontalCollectionCell.identfier)
    }
  }
  @IBOutlet weak var imgProfile: UIImageView!
  @IBOutlet weak var lblName: UILabel!
  @IBOutlet weak var lblLocation: UILabel!
  
  //MARK:- Properties
  private var dataSource: TableDataSource<HeaderFooterData>?
  private var business: BusineesPageObject? {
    didSet {
      dataSource?.updateAndReload(for: .MultipleSection(items: HeaderFooterData.getHomeItems(businessObj: business, freinds: friends ?? [])), .FullReload)
    }
  }
  private var friends: [UserData]? {
    didSet {
      dataSource?.updateAndReload(for: .MultipleSection(items: HeaderFooterData.getHomeItems(businessObj: business, freinds: friends ?? [])), .FullReload)
    }
  }
  private var presentationTypeExperiences = HorizontalCollectionLoad.GettingLocation
  private var presentationTypeFriends = HorizontalCollectionLoad.GettingLocation
  private var isFirstTime = true
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableViewSetup()
    handleLocation()
    profileInfoSetup()
    SocketIOManager.shared.connect(for: .AppActive)
    SocketIOManager.shared.getNearByBusinesses(for: .AppActive) { [weak self] (response) in
      if !(/self?.business?.data?.containSameElements(response?.data ?? [])) {
        self?.presentationTypeExperiences = /response?.data?.count == 0 ? .NoNearByExperiences : .DataLoaded
        self?.business = response
      }
    }
    if CommonFuncs.shared.isUserLoggedIn(showPopUp: false, canBeCancelled: true) {
      EP_Other.getProfile.request(success: { [weak self] (response) in
        let tempData = UserPreference.shared.data
        tempData?.imageUrl = (response as? UserData)?.imageUrl
        UserPreference.shared.data = tempData
        self?.profileInfoSetup()
      })
    }
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(true)
    profileInfoSetup()
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  @IBAction func tfSearchAction(_ sender: UITextField) {
    sender.resignFirstResponder()
    let destVC = StoryboardScene.Other.SearchVC.instantiate()
    pushVC(destVC)
  }
}

//MARK:-VCFuncs
extension HomeVC {
  //MARK:- TableView Blocks setup
  private func tableViewSetup() {
    
    tableView.addSKPullToRefresh { [weak self] in
      self?.getNearByFriendsAPI()
      self?.getNearByBusinessAPI()
      self?.tableView.stopSKRefresh()
    }
    
    dataSource = TableDataSource<HeaderFooterData>(.MultipleSection(items: HeaderFooterData.getHomeItems(businessObj: business, freinds: [])), tableView)

    dataSource?.configureHeaderFooter = { (section, item, view, isHeader) in
      (view as? HomeSection)?.item = item
    }
    
    dataSource?.configureCell = { [weak self] (cell, item, indexPath, property) in
      (cell as? HorizontalCollectionCell)?.item = item
      guard let expType = self?.presentationTypeExperiences else {
        return
      }
      guard let friendType = self?.presentationTypeFriends else {
        return
      }
      switch indexPath.section {
      case 0: // NearByExperiences
        (cell as? HorizontalCollectionCell)?.presentationType = expType
        (cell as? HorizontalCollectionCell)?.didTapRetry = {
          self?.getNearByBusinessAPI()
        }
      case 1: // NearByFriends
        (cell as? HorizontalCollectionCell)?.presentationType = friendType
        (cell as? HorizontalCollectionCell)?.didTapRetry = {
          self?.getNearByFriendsAPI()
        }
      default:
        break
      }
    }
  }
  
  //MARK:- Location Handling and first viewdidload() api's hit
  private func handleLocation() {
    LocationManager.shared.isLocationEnabled {  [weak self] (isLocationEnabled) in
      if !isLocationEnabled {
        self?.isFirstTime = true
        self?.presentationTypeExperiences = .LocationDisabled
        self?.presentationTypeFriends = .LocationDisabled
        self?.business = nil
        self?.friends = []
      }
    }
    LocationManager.shared.startTrackingUser { [weak self] (location) in
      self?.generateAddress(latLng: location)
      if /self?.isFirstTime {
        self?.getNearByBusinessAPI()
        self?.getNearByFriendsAPI()
        self?.isFirstTime = false
      }
    }
  }
  
  //MARK:- Get Address String from latitude longitude
  private func generateAddress(latLng: LocationManagerData?) {
    let location = CLLocation.init(latitude: /latLng?.latitude, longitude: /latLng?.longitude)
    CLGeocoder().reverseGeocodeLocation(location) { [weak self] (placeMarks, error) in
      let tempData = UserPreference.shared.data
      tempData?.currentArea = /placeMarks?.first?.subLocality + ", " + /placeMarks?.first?.postalAddress?.city
      UserPreference.shared.data = tempData
      self?.lblLocation.text = /placeMarks?.first?.subLocality + ", " + /placeMarks?.first?.postalAddress?.city
    }
  }
  
  //MARK:- User info to be setup whenever changed
  private func profileInfoSetup() {
    let preference = UserPreference.shared.data
    imgProfile.setImageKF(preference?.imageUrl?.thumbnail, placeHolder: #imageLiteral(resourceName: "ic_profile_placeholder"))
    imgProfile.isHidden = !(/preference?.isVerified)
    lblName.text = preference?.name ?? VCLiteral.GUEST_USER.localized
    imgProfile.addTapGestureRecognizer { [weak self] in
      let destVC = StoryboardScene.Other.ProfileVC.instantiate()
      self?.pushVC(destVC)
    }
  }
  
  //MARK:- Get nearby businesses api
  func getNearByBusinessAPI() {
    presentationTypeExperiences = .LoadingExperiencesFromAPI
    business = nil
    EP_Other.nearByBusiness(pageNo: String(0), businessId: nil).request(success: { [weak self] (response) in
      let data = (response as? BusineesPageObject)
      if /data?.data?.count == 0 {
        self?.presentationTypeExperiences = .NoNearByExperiences
        self?.business = nil
      } else {
        self?.presentationTypeExperiences = .DataLoaded
        self?.business = data
      }
    }) { [weak self] (error) in
      self?.presentationTypeExperiences = .CustomError(error: /error)
      self?.business = nil
    }
  }
  
  //MARK:- Get nearby friends api
  func getNearByFriendsAPI() {
    if !(/UserPreference.shared.data?.isVerified) {
      presentationTypeFriends = .NoFriendsGuestLogin
      friends = []
      return
    }
    presentationTypeFriends = .LoadingFriendsFromAPI
    friends = []
    EP_Other.nearByFriends(pageNo: String(0)).request(success: { [weak self] (response) in
      let data = (response as? [UserData]) ?? []
      if data.count == 0 {
        self?.presentationTypeFriends = .NoNearByFriends
        self?.friends = []
      } else {
        self?.presentationTypeFriends = .DataLoaded
        self?.friends = data
      }
    }) { [weak self] (error) in
      self?.presentationTypeFriends = .CustomError(error: /error)
      self?.friends = []
    }
  }
}
