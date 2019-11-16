//
//  ListingVC.swift
//  AE
//
//  Created by MAC_MINI_6 on 10/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

class ListingVC: BaseVC {
  
  @IBOutlet weak var navBar: UIView!
  @IBOutlet weak var btnBack: UIButton!
  @IBOutlet weak var lblTitle: UILabel!
  @IBOutlet weak var lblSubTitle: UILabel!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var titleTopConstraint: NSLayoutConstraint! // 44 or 0
  @IBOutlet weak var tableViewTop: NSLayoutConstraint! // 8 / 0
  
  var listingType: ListingType = .NearbyBusiness
  private var dataSource: TableDataSource<HeaderFooterData>?
  private var items: [Any]?
  private var pageNo = 0
  private var downloadedFilesArray : [String] = []
  private var businessMain: Business?
  
  lazy var downloadManager: MZDownloadManager = {
    [unowned self] in
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let downloadmanager = appDelegate.downloadManager
    return downloadmanager
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    initialSetup()
    
    switch listingType {
    case .BusinessDetailObjects(_):
      handleDownloadBlocks()
    default:
      break
    }
  }
  
  @IBAction func btnBackAction(_ sender: UIButton) {
    popVC()
  }
  
}

//MARK:- VCFuncs
extension ListingVC {
  //MARK:- Initial UI Setup
  private func initialSetup() {
    lblTitle.text = listingType.property.title
    lblSubTitle.text = /listingType.property.subtitle
    tableView.separatorStyle = listingType.property.separatorStyle
    tableView.registerXIB(listingType.property.identifier)
    
    //MARK:- TableView DataSource initialization
    dataSource = TableDataSource<HeaderFooterData>(.SingleListing(items: items ?? [], identifier: listingType.property.identifier, height: listingType.property.cellHeight), tableView, true)
    
    dataSource?.configureCell = { [weak self] (cell, item, indexPath, _) in
      guard let type = self?.listingType else {
        return
      }
      switch type {
      case .NearbyBusiness:
        (cell as? BusinessListingCell)?.item = item
      case .NearbyFriends:
        (cell as? FriendListingCell)?.item = item
      case .BusinessDetailPackages(_):
        (cell as? PackageCell)?.item = item
      case .BusinessDetailObjects(_):
        (cell as? ThreeD_ObjectCell)?.btnDownload.tag = indexPath.row
        (cell as? ThreeD_ObjectCell)?.btnDownload.addTarget(self, action: #selector(self?.downloadObjectAction(sender:)), for: .touchUpInside)
        (cell as? ThreeD_ObjectCell)?.item = item
      case .BusinessBranches(_):
        (cell as? BranchListingCell)?.item = item
      }
    }
    
    dataSource?.didSelectRow = { [weak self] (indexPath, item, _) in
      self?.cellTapRedirection(obj: item)
    }
    
    dataSource?.scrollDirection = { [weak self] (direction) in
      if direction == .Down {
        self?.navBar.isHidden = true
      }
      self?.navigationBarAnimationHandling(direction: direction)
    }
    
    dataSource?.addInfiniteScrolling = { [weak self] in
      self?.pageNo = /self?.pageNo + 1
      self?.apiForListing()
    }
    
    dataSource?.addPullToRefresh = { [weak self] in
      self?.pageNo = 0
      self?.items = []
      self?.dataSource?.updateAndReload(for: .SingleListing(items: self?.items ?? []), .FullReload)
      self?.apiForListing()
    }
    
    dataSource?.refreshProgrammatically()
  }
  
  private func cellTapRedirection(obj: Any?) {
    switch listingType {
    case .NearbyBusiness:
      let destVC = StoryboardScene.Other.BusinessDetailVC.instantiate()
      destVC.business = obj as? Business
      pushVC(destVC)
    case .BusinessBranches(_):
      let destVC = StoryboardScene.Other.BusinessDetailVC.instantiate()
      destVC.business = obj as? Business
      destVC.isNavigatedViaBranches = true
      pushVC(destVC)
    case .BusinessDetailPackages(let business):
      let destVC = StoryboardScene.Other.PackageDetailVC.instantiate()
      destVC.business = business
      destVC.package = obj as? Package
      pushVC(destVC)
    case .BusinessDetailObjects(_):
      if (obj as? Object)?.objectUrl?.downloadStatus == .DOWNLOADED || (obj as? Object)?.mediaUrlSigned?.downloadStatus == .DOWNLOADED {
        switch (obj as? Object)?.mediaType ?? .OBJECT {
        case .OBJECT:
          tapObjectAction(with: obj as? Object)
        default:
          mediaPreview(with: obj as? Object)
        }
      } else {
          Toast.shared.showAlert(type: .validationFailure, message: VCLiteral.DOWNLOAD_FIRST.localized)
      }
    default:
      break
    }
  }
  
  private func apiForListing() {
    getEndPoint()?.request(success: { [weak self] (response) in
      let newItems = self?.parseModelByType(response: response) ?? []
      self?.dataSource?.stopInfiniteLoading(newItems.count == 0 ? .NoContentAnyMore : .FinishLoading)
      self?.items = (self?.items ?? []) + newItems
      self?.dataSource?.updateAndReload(for: .SingleListing(items: self?.items ?? []), .FullReload)
    }, error: { [weak self] (error) in
      if /self?.pageNo != 0 {
        self?.pageNo = /self?.pageNo - 1
      }
      self?.dataSource?.stopInfiniteLoading(.FinishLoading)
    })
  }
  
  private func getEndPoint() -> EP_Other? {
    switch listingType {
    case .NearbyBusiness:
      return .nearByBusiness(pageNo: String(pageNo), businessId: nil)
    case .NearbyFriends:
      return .nearByFriends(pageNo: String(pageNo))
    case .BusinessDetailPackages(let business):
      businessMain = business
      return EP_Other.packageListing(businessId: business?._id, packageId: nil, pageNo: String(pageNo))
    case .BusinessDetailObjects(let business):
      businessMain = business
      return EP_Other.objectListing(objectId: nil, businessId: business?._id, packageId: nil, pageNo: String(pageNo))
    case .BusinessBranches(let business):
      businessMain = business
      var endPoint: EP_Other?
      if let masterId = business?.masterBranchId {
        endPoint = EP_Other.nearByBusiness(pageNo: String(pageNo), businessId: masterId)
      } else {
        endPoint = EP_Other.nearByBusiness(pageNo: String(pageNo), businessId: business?._id)
      }
      return endPoint
    }
  }
  
  private func parseModelByType(response: Any?) -> [Any]? {
    switch listingType {
    case .NearbyBusiness,
         .BusinessBranches(_):
      return (response as? BusineesPageObject)?.data
    case .NearbyFriends:
      return (response as? [UserData])
    case .BusinessDetailPackages(_):
      return (response as? [Package])
    case .BusinessDetailObjects(_):
      let objects = (response as? [Object])
      DownloadPreference.shared.syncObjectsForURLs(backendObjects: objects)
      return DownloadPreference.shared.getSyncedObjectsForStatus(backendObjects: objects)
    }
  }
  //MARK:- Handling Animation for navigation bar
  private func navigationBarAnimationHandling(direction: ScrollDirection) {
    tableViewTop.constant = direction == .Up ? 0 : 8.0
    titleTopConstraint.constant = direction == .Up ? 0 : 44
    lblSubTitle.text = direction == .Up ? nil : /listingType.property.subtitle
    UIView.transition(with: lblTitle, duration: 0.2, options: .curveLinear, animations: { [weak self] in
      self?.lblTitle.textAlignment = direction == .Up ? .center : .left
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

//MARK:- 3D Objects Screen functions
extension ListingVC {
  
  @objc func downloadObjectAction(sender: UIButton) {
    
    
    if !CommonFuncs.shared.isUserLoggedIn(showPopUp: true, canBeCancelled: true) {
      return
    }
    
    if /businessMain?.isFollowing == false {
      Toast.shared.showAlert(type: .validationFailure, message: VCLiteral.FOLLOW_BUSINESS_ALERT_FOR_DOWNLOAD.localized)
      return
    }
    
    let item = items?[sender.tag] as? Object

    DownloadPreference.shared.addObjToDownloads(obj: item) { [weak self] (isAlreadyExists) in
      if /isAlreadyExists {
        Toast.shared.showAlert(type: .validationFailure, message: VCLiteral.DOWNLOAD_ALREADY_EXIST.localized)
      } else {
        
        if item?.objectUrl == nil {
          let components = item?.mediaUrlSigned?.thumbnail?.components(separatedBy: "/")
          let fileName = (/components?.first(where: { $0.contains("thumb_") })).components(separatedBy: "?").first
          
          item?.mediaUrlSigned?.downloadStatus = .PENDING
          item?.mediaUrlSigned?.fileName = fileName
          item?.imageUrl?.forEach({$0.downloadStatus = .PENDING})
          self?.items?[sender.tag] = item!
          self?.dataSource?.updateAndReload(for: .SingleListing(items: self?.items ?? []), .Reload(indexPaths: [IndexPath.init(row: sender.tag, section: 0)], animation: .none))
          
         
          self?.downloadManager.addDownloadTask(/fileName, request: URLRequest(url: URL.init(string: /item?.mediaUrlSigned?.thumbnail)!), destinationPath: MZUtility.baseFilePath)
          
          item?.imageUrl?.forEach({ (image) in
            self?.downloadManager.addDownloadTask(/image.fileName, request: URLRequest(url: URL.init(string: /image.original)!), destinationPath: MZUtility.baseFilePath)
          })
        } else {
          item?.objectUrl?.downloadStatus = .PENDING
          item?.imageUrl?.forEach({$0.downloadStatus = .PENDING})
          self?.items?[sender.tag] = item!
          
          self?.dataSource?.updateAndReload(for: .SingleListing(items: self?.items ?? []), .Reload(indexPaths: [IndexPath.init(row: sender.tag, section: 0)], animation: .none))
          
          self?.downloadManager.addDownloadTask(/item?.objectUrl?.fileName, request: URLRequest(url: URL.init(string: /item?.objectUrl?.gltf)!), destinationPath: MZUtility.baseFilePath)
          self?.downloadManager.addDownloadTask(/item?.objectUrl?.thumbnailName, request: URLRequest(url: URL.init(string: /item?.objectUrl?.thumbnail)!), destinationPath: MZUtility.baseFilePath)
          item?.imageUrl?.forEach({ (image) in
            self?.downloadManager.addDownloadTask(/image.fileName, request: URLRequest(url: URL.init(string: /image.original)!), destinationPath: MZUtility.baseFilePath)
          })
          
        }
        EP_Other.downloadObject(objId: item?._id, packageId: nil).request(success: { (_) in })

      }
    }
  }

  func handleDownloadBlocks() {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    appDelegate.downloadRequestStatus = { [weak self] (downloadModel, status) in
      if let index: Int = self?.items?.firstIndex(where: { ($0 as? Object)?.objectUrl?.fileName == /downloadModel.fileName }) {
        (self?.items?[index] as? Object)?.objectUrl?.downloadStatus = status
        (self?.items?[index] as? Object)?.downloadValues = DownloadValues(downloadModel: downloadModel)
        self?.dataSource?.updateAndReload(for: .SingleListing(items: self?.items ?? []), .None)
        self?.refreshCellForIndex((self?.items?[index] as? Object), index: index)
//        if status == .DOWNLOADED {
//          EP_Other.downloadObject(objId: (self?.items?[index] as? Object)?._id, packageId: nil).request(success: { (_) in })
//        }
      } else if let index: Int = self?.items?.firstIndex(where: { ($0 as? Object)?.mediaUrlSigned?.fileName == /downloadModel.fileName }) {
        (self?.items?[index] as? Object)?.mediaUrlSigned?.downloadStatus = status
        (self?.items?[index] as? Object)?.downloadValues = DownloadValues(downloadModel: downloadModel)
        self?.dataSource?.updateAndReload(for: .SingleListing(items: self?.items ?? []), .None)
        self?.refreshCellForIndex((self?.items?[index] as? Object), index: index)
//        if status == .DOWNLOADED {
//          EP_Other.downloadObject(objId: (self?.items?[index] as? Object)?._id, packageId: nil).request(success: { (_) in })
//        }
      }
      
    }
  }
  
  func refreshCellForIndex(_ downloadModel: Object?, index: Int) {
    if /items?.count > 0 {
      let indexPath = IndexPath.init(row: index, section: 0)
      let cell = self.tableView.cellForRow(at: indexPath)
      if let downloadCell = cell as? ThreeD_ObjectCell {
        downloadCell.item = downloadModel
      }
    }
  }
  
}
