//
//  PackageDetailVC.swift
//  AE
//
//  Created by MAC_MINI_6 on 29/05/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

class PackageDetailVC: BaseVC {

  @IBOutlet weak var navBar: UIView!
  @IBOutlet weak var btnBack: UIButton!
  @IBOutlet weak var lblTitle: UILabel!
  @IBOutlet weak var lblSubTitle: UILabel!
  @IBOutlet weak var tableView: UITableView! {
    didSet {
      tableView.registerXIB(PackageDetailCell.identfier)
      tableView.registerXIB(ThreeD_ObjectCell.identfier)
      tableView.registerXIBForHeaderFooter(PackageDetailSectionView.identfier)
    }
  }
  @IBOutlet weak var titleTopConstraint: NSLayoutConstraint! // 44 or 0
  @IBOutlet weak var tableViewTop: NSLayoutConstraint! // 8 / 0
  
  
  lazy var downloadManager: MZDownloadManager = {
    [unowned self] in
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let downloadmanager = appDelegate.downloadManager
    return downloadmanager
  }()
  
  var package: Package?
  var business: Business?
  var isDownloadedDetail: Bool = false
  
  private var items: [Object]? {
    didSet {
      dataSource?.updateAndReload(for: .MultipleSection(items: HeaderFooterData.getPackageDetailListing(package: package, objects: items, isDownloaded: isDownloadedDetail)), .FullReload)
    }
  }
  private var dataSource: TableDataSource<HeaderFooterData>?
  private var pageNo = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    lblSubTitle.text = String(format: VCLiteral.AR_PACKAGE_BY.localized, arguments: [/business?.name])
    tableViewSetUp()
    if /isDownloadedDetail {
      getDownloadedObjects()
    } else {
      getObjectsAPI()
    }
    handleDownloadBlocks()
  }
  
  @IBAction func btnBackAction(_ sender: UIButton) {
    popVC()
  }
  
}

//MARK:- VCFuncs
extension PackageDetailVC {
  
  private func tableViewSetUp() {
    dataSource = TableDataSource<HeaderFooterData>(.MultipleSection(items: HeaderFooterData.getPackageDetailListing(package: package, objects: items, isDownloaded: isDownloadedDetail)), tableView, true)
    
    dataSource?.configureCell = { [weak self] (cell, item, indexPath, property) in
      switch /property?.cellIdentifier {
      case PackageDetailCell.identfier:
        (cell as? PackageDetailCell)?.isDownloaded = self?.isDownloadedDetail
        (cell as? PackageDetailCell)?.item = item
      case ThreeD_ObjectCell.identfier:
        (cell as? ThreeD_ObjectCell)?.item = item
        (cell as? ThreeD_ObjectCell)?.btnDownload.tag = indexPath.row
        (cell as? ThreeD_ObjectCell)?.btnDownload.addTarget(self, action: #selector(self?.downloadObjectAction(sender:)), for: .touchUpInside)
      case DownloadedObjectCell.identfier:
        (cell as? DownloadedObjectCell)?.item = item
        (cell as? DownloadedObjectCell)?.btnOptionsTapped = { [weak self] in
          self?.deleteItemAt(index: indexPath.row)
        }
      default:
        break
      }
    }
    
    dataSource?.scrollDirection = { [weak self] (direction) in
      if direction == .Down {
        self?.navBar.isHidden = true
      }
      self?.navigationBarAnimationHandling(direction: direction)
    }
    
    dataSource?.didSelectRow = { [weak self] (indexPath, item, property) in
      if /indexPath.section == 0 {
        return
      }
      let obj = item as? Object
      if obj?.objectUrl?.downloadStatus == .DOWNLOADED || obj?.mediaUrlSigned?.downloadStatus == .DOWNLOADED {
        switch obj?.mediaType ?? .OBJECT {
        case .OBJECT:
          self?.tapObjectAction(with: obj)
        default:
         self?.mediaPreview(with: obj)
        }
      } else {
        Toast.shared.showAlert(type: .validationFailure, message: VCLiteral.DOWNLOAD_FIRST.localized)
      }
    }
    
    dataSource?.addPullToRefresh = { [weak self] in
      if !(/self?.isDownloadedDetail) {
        self?.pageNo = 0
        self?.items = []
        self?.getObjectsAPI()
      } else {
        self?.getDownloadedObjects()
      }
    }
    
    dataSource?.addInfiniteScrolling = { [weak self] in
      if !(/self?.isDownloadedDetail) {
        self?.pageNo = /self?.pageNo + 1
        self?.getObjectsAPI()
      }
    }
  }
  
  @objc func downloadObjectAction(sender: UIButton) {
    if !CommonFuncs.shared.isUserLoggedIn(showPopUp: true, canBeCancelled: true) {
      return
    }
    
    if /business?.isFollowing == false {
      Toast.shared.showAlert(type: .validationFailure, message: VCLiteral.FOLLOW_BUSINESS_ALERT_FOR_DOWNLOAD.localized)
      return
    }
    
    let item = items?[sender.tag]
    item?.packageId = package
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
          
//          self?.dataSource?.updateAndReload(for: .MultipleSection(items: HeaderFooterData.getPackageDetailListing(package: self?.package, objects: self?.items, isDownloaded: self?.isDownloadedDetail)), .Reload(indexPaths: [IndexPath.init(row: sender.tag, section: 1)], animation: .none))
//          self?.dataSource?.updateAndReload(for: .SingleListing(items: self?.items ?? []), .Reload(indexPaths: [IndexPath.init(row: sender.tag, section: 1)], animation: .none))
          
          
          self?.downloadManager.addDownloadTask(/fileName, request: URLRequest(url: URL.init(string: /item?.mediaUrlSigned?.thumbnail)!), destinationPath: MZUtility.baseFilePath)
          
          item?.imageUrl?.forEach({ (image) in
            self?.downloadManager.addDownloadTask(/image.fileName, request: URLRequest(url: URL.init(string: /image.original)!), destinationPath: MZUtility.baseFilePath)
          })
        } else {
          item?.objectUrl?.downloadStatus = .PENDING
          item?.imageUrl?.forEach({$0.downloadStatus = .PENDING})
          item?.packageId?.imageUrl?.downloadStatus = .PENDING
          self?.items?[sender.tag] = item!
          
          self?.downloadManager.addDownloadTask(/item?.objectUrl?.fileName, request: URLRequest(url: URL.init(string: /item?.objectUrl?.gltf)!), destinationPath: MZUtility.baseFilePath)
          self?.downloadManager.addDownloadTask(/item?.objectUrl?.thumbnailName, request: URLRequest(url: URL.init(string: /item?.objectUrl?.thumbnail)!), destinationPath: MZUtility.baseFilePath)
          item?.imageUrl?.forEach({ (image) in
            self?.downloadManager.addDownloadTask(/image.fileName, request: URLRequest(url: URL.init(string: /image.original)!), destinationPath: MZUtility.baseFilePath)
          })
          
//          do {
//            let contentOfDir: [String] = try FileManager.default.contentsOfDirectory(atPath: MZUtility.baseFilePath as String)
//            if /contentOfDir.contains(/item?.packageId?.imageUrl?.fileName) {
//              print("Package Thumbnail exists")
//            } else {
//              self?.downloadManager.addDownloadTask(/item?.packageId?.imageUrl?.fileName, request: URLRequest(url: URL.init(string: /item?.packageId?.imageUrl?.original)!), destinationPath: MZUtility.baseFilePath)
//            }
//          } catch let error as NSError {
//            print("Error while getting directory content \(error)")
//          }
        }
        EP_Other.downloadObject(objId: item?._id, packageId: self?.package?._id).request(success: { (_) in })
      }
    }
  }
  
  private func deleteItemAt(index: Int) {
    actionSheet(for: [VCLiteral.DELETE.localized], title: String.init(format: VCLiteral.DELETE_OBJECT_ALERT.localized, /items?[index].name), message: nil) { [weak self] (selectedString) in
      DownloadPreference.shared.delete(obj: self?.items?[index])
      self?.items?.remove(at: index)
    }
  }
  
  private func handleDownloadBlocks() {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    appDelegate.downloadRequestStatus = { [weak self] (downloadModel, status) in
      
      if let index: Int = self?.items?.firstIndex(where: { ($0).objectUrl?.fileName == /downloadModel.fileName }) {
        (self?.items?[index])?.objectUrl?.downloadStatus = status
        (self?.items?[index])?.downloadValues = DownloadValues(downloadModel: downloadModel)
        
        
        self?.dataSource?.updateAndReload(for: .MultipleSection(items: HeaderFooterData.getPackageDetailListing(package: self?.package, objects: self?.items, isDownloaded: self?.isDownloadedDetail)), .None)
        self?.refreshCellForIndex((self?.items?[index]), index: index)
      } else if let index: Int = self?.items?.firstIndex(where: { ($0).mediaUrlSigned?.fileName == /downloadModel.fileName }) {
        (self?.items?[index])?.mediaUrlSigned?.downloadStatus = status
        (self?.items?[index])?.downloadValues = DownloadValues(downloadModel: downloadModel)
//        self?.dataSource?.updateAndReload(for: .SingleListing(items: self?.items ?? []), .None)
        self?.dataSource?.updateAndReload(for: .MultipleSection(items: HeaderFooterData.getPackageDetailListing(package: self?.package, objects: self?.items, isDownloaded: self?.isDownloadedDetail)), .None)
        self?.refreshCellForIndex((self?.items?[index]), index: index)
      }
      
      
      
      
//      guard let index: Int = self?.items?.firstIndex(where: { $0.objectUrl?.fileName == /downloadModel.fileName }) else {
//        return
//      }
//      self?.items?[index].objectUrl?.downloadStatus = status
//      self?.items?[index].downloadValues = DownloadValues(downloadModel: downloadModel)
//      self?.dataSource?.updateAndReload(for: .MultipleSection(items: HeaderFooterData.getPackageDetailListing(package: self?.package, objects: self?.items, isDownloaded: self?.isDownloadedDetail)), .None)
//      self?.refreshCellForIndex(self?.items?[index], index: index)
    }
  }
  
  private func refreshCellForIndex(_ downloadModel: Object?, index: Int) {
    if /items?.count > 0 {
      let indexPath = IndexPath.init(row: index, section: 1)
      if let downloadCell = tableView.cellForRow(at: indexPath) as? ThreeD_ObjectCell {
        downloadCell.item = downloadModel
      }
    }
  }
  
  private func getObjectsAPI() {
    EP_Other.objectListing(objectId: nil, businessId: nil, packageId: package?._id, pageNo: String(pageNo)).request(success: { [weak self] (response) in
      let newItems = (response as? [Object]) ?? []
      self?.dataSource?.stopInfiniteLoading(newItems.count == 0 ? .NoContentAnyMore : .FinishLoading)
      self?.items = (self?.items ?? []) + DownloadPreference.shared.getSyncedObjectsForStatus(backendObjects: newItems) 
    }) { [weak self] (error) in
      if /self?.pageNo != 0 {
        self?.pageNo = /self?.pageNo - 1
      }
      self?.dataSource?.stopInfiniteLoading(.FinishLoading)
    }
  }
  
  private func getDownloadedObjects() {
    items = DownloadPreference.shared.getObjects(for: package)
    dataSource?.stopInfiniteLoading(.FinishLoading)
  }
  
  //MARK:- Handling Animation for navigation bar
  private func navigationBarAnimationHandling(direction: ScrollDirection) {
    tableViewTop.constant = direction == .Up ? 0 : 8.0
    titleTopConstraint.constant = direction == .Up ? 0 : 44
    lblSubTitle.text = direction == .Up ? nil : String(format: VCLiteral.AR_PACKAGE_BY.localized, arguments: [/business?.name])
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
