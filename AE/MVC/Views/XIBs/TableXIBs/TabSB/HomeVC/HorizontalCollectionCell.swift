//
//  HorizontalCollectionCell.swift
//  AE
//
//  Created by MAC_MINI_6 on 08/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

class HorizontalCollectionCell: UITableViewCell, ReusableCell {

  @IBOutlet weak var collectionView: UICollectionView! {
    didSet {
      collectionView.registerXIB(HomeBusinessCell.identfier)
      collectionView.registerXIB(HomeFriendCell.identfier)
      collectionView.registerXIB(ImageCell.identfier)
      collectionView.registerXIB(BusinessDetailObjCell.identfier)
    }
  }
  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var indicator: UIActivityIndicatorView!
  @IBOutlet weak var lblMessage: UILabel!
  @IBOutlet weak var btn: UIButton!
  
  var didTapRetry: (() -> Void)?
  var presentationType: HorizontalCollectionLoad = .DataLoaded {
    didSet {
      handlePresentation()
    }
  }
  
  var dataSource: CollectionDataSource?
  
  lazy var downloadManager: MZDownloadManager = {
    [unowned self] in
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let downloadmanager = appDelegate.downloadManager
    return downloadmanager
  }()

  var business: Business?
  
  var item: Any? {
    didSet {
      if let businesses = (item as? HomeBusiness)?.items { //Home Screen Horizontal Listing
        
        let width = (ScreenSize.SCREEN_WIDTH - 48) * (144 / 216)
        dataSource = CollectionDataSource.init(businesses, HomeBusinessCell.identfier, collectionView, CGSize.init(width: width, height: width * 0.66), UIEdgeInsets.init(top: 20, left: 24, bottom: 20, right: 24), 16.0, 0.0)
        
      } else if let friends = (item as? HomeFriend)?.items { //Home Screen NearBy Friends Listing
        
        dataSource = CollectionDataSource.init(friends, HomeFriendCell.identfier, collectionView, CGSize.init(width: 88.0, height: TableHeight.HomeFriendCell), UIEdgeInsets.init(top: 0, left: 24, bottom: 0, right: 24), 16.0, 0.0)
        
      } else if let images = (item as? GalleryImages)?.items { //Business detail screen Gallery
        
        dataSource = CollectionDataSource.init(images, ImageCell.identfier, collectionView, CollectionSize.BusinessGallery, UIEdgeInsets.init(top: 8, left: 24, bottom: 24, right: 24), 8.0, 0.0)
        
      } else if let objects = (item as? BusinessDetail_3DObjects)?.items { //Business detail 3d objects
        handleDownloadBlocks()
        dataSource = CollectionDataSource.init(objects, BusinessDetailObjCell.identfier, collectionView, CollectionSize.BusinessObjects, UIEdgeInsets.init(top: 8, left: 24, bottom: 24, right: 24), 8.0, 0.0)
        
      }
      
      dataSource?.configureCell = { (cell, item, indexPath) in
        (cell as? HomeBusinessCell)?.item = item
        (cell as? HomeFriendCell)?.item = item
        (cell as? ImageCell)?.item = item
        (cell as? BusinessDetailObjCell)?.item = item
      }
      
      dataSource?.didSelectItem = { [weak self] (indexPath, selectedItem) in
        if let business = (selectedItem as? Business) {
          let destVC = StoryboardScene.Other.BusinessDetailVC.instantiate()
          destVC.business = business
          UIApplication.topVC()?.pushVC(destVC)
        } else if let obj = selectedItem as? Object {
          self?.handleObjectTap(index: indexPath.item, obj: obj)
        } else if let obj = selectedItem as? Gallery {
          switch obj.fileUrl?.type ?? .IMAGE {
          case .IMAGE:
            guard let image = obj.fileUrl else { return }
            let destVC = StoryboardScene.Other.MediaPreviewVC.instantiate()
            destVC.item = ([image], 0)
            UIApplication.topVC()?.pushVC(destVC)
          case .IMAGE360:
            let destVC = StoryboardScene.Other.Image360VC.instantiate()
            destVC.url = URL(string: /obj.fileUrl?.original)
            UIApplication.topVC()?.presentVC(destVC)
          case .VIDEO:
            UIApplication.topVC()?.playVideo(URL(string: /obj.fileUrl?.original))
          case .VIDEO360:
            let destVC = StoryboardScene.Other.Video360VC.instantiate()
            destVC.urlString = /obj.fileUrl?.original
            UIApplication.topVC()?.presentVC(destVC)
          case .OBJECT:
            break
          }
        } else if let user = selectedItem as? UserData {
          UIApplication.topVC()?.navigate(lat: /user.latLong?.last, lng: /user.latLong?.first)
        }
      }
      
    }
  }
  
  func handlePresentation() {
    indicator.startAnimating()
    stackView.isHidden = presentationType.showMainView
    lblMessage.text = /presentationType.message
    btn.setTitle(/presentationType.btnTitle?.localized, for: .normal)
    btn.isHidden = !presentationType.showButton
    indicator.isHidden = !presentationType.showLoader
  }
  
  @IBAction func btnAction(_ sender: UIButton) {
    if presentationType.btnTitle == VCLiteral.SETTINGS {
      UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
    } else if presentationType.btnTitle == VCLiteral.SIGNUP {
      CommonFuncs.shared.storyboardReInstantiateFor(.Logout)
    } else if presentationType.btnTitle == VCLiteral.RETRY {
      didTapRetry?()
    }
  }
  
}

//MARK:- Business 3d objets download code
extension HorizontalCollectionCell {
  func handleObjectTap(index: Int, obj: Object) {
    if (obj.objectUrl?.downloadStatus ?? .NONE) == .DOWNLOADED || (obj.mediaUrlSigned?.downloadStatus ?? .NONE) == .DOWNLOADED {
      
      switch obj.mediaType ?? .OBJECT {
      case .OBJECT:
        UIApplication.topVC()?.actionSheet(for: [VCLiteral.OBJECT_VIEW_OPTION_1.localized,
                                                 VCLiteral.OBJECT_VIEW_OPTION_2.localized], title: VCLiteral.OBJECT_VIEW_TITLE.localized, message: nil) { (tappedTitle) in
                                                  switch tappedTitle {
                                                  case VCLiteral.OBJECT_VIEW_OPTION_1.localized: //Camera
                                                    (UIApplication.topVC() as? BusinessDetailVC)?.openARCameraVC(with: obj)
                                                  case VCLiteral.OBJECT_VIEW_OPTION_2.localized: // 3D Scene
                                                    let destVC = StoryboardScene.Other.ObjPreviewVC.instantiate()
                                                    destVC.obj = obj
                                                    UIApplication.topVC()?.pushVC(destVC)
                                                  default: break
                                                  }
        }
      default:
        (UIApplication.topVC() as? BusinessDetailVC)?.mediaPreview(with: obj)
      }
      
    
    } else if (obj.objectUrl?.downloadStatus ?? .NONE) == .NONE {
      if /business?.isFollowing == false {
        Toast.shared.showAlert(type: .validationFailure, message: VCLiteral.FOLLOW_BUSINESS_ALERT_FOR_DOWNLOAD.localized)
      } else {
        UIApplication.topVC()?.actionSheet(for: [VCLiteral.DOWNLOAD.localized], title: VCLiteral.DOWNLOAD_FIRST.localized, message: nil, tapped: { (tappedString) in
          if tappedString == VCLiteral.DOWNLOAD.localized {
            //start downloading
            self.startDownloadAction(index: index, obj: obj)
          }
        })
      }
    }
  }
  
  func handleDownloadBlocks() {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    appDelegate.downloadRequestStatus = { [weak self] (downloadModel, status) in
      let items = (self?.item as? BusinessDetail_3DObjects)?.items
      
      if let index: Int = items?.firstIndex(where: { /$0.objectUrl?.fileName == /downloadModel.fileName}) {
        items?[index].objectUrl?.downloadStatus = status
        items?[index].downloadValues = DownloadValues(downloadModel: downloadModel)
        self?.dataSource?.items = items
        self?.item = BusinessDetail_3DObjects(backendArray: items)
        self?.refreshCellForIndex(items?[index], index: index)
//        if status == .DOWNLOADED {
//          EP_Other.downloadObject(objId: items?[index]._id, packageId: nil).request(success: { (_) in })
//        }
      } else if let index: Int = items?.firstIndex(where: { /$0.mediaUrlSigned?.fileName == /downloadModel.fileName}) {
        items?[index].mediaUrlSigned?.downloadStatus = status
        items?[index].downloadValues = DownloadValues(downloadModel: downloadModel)
        self?.dataSource?.items = items
        self?.item = BusinessDetail_3DObjects(backendArray: items)
        self?.refreshCellForIndex(items?[index], index: index)
//        if status == .DOWNLOADED {
//          EP_Other.downloadObject(objId: items?[index]._id, packageId: nil).request(success: { (_) in })
//        }
      }
      
    }
  }
  
  
  func refreshCellForIndex(_ downloadModel: Object?, index: Int) {
    let items = (item as? BusinessDetail_3DObjects)?.items
    if /items?.count > 0 {
      let indexPath = IndexPath.init(row: index, section: 0)
      let cell = collectionView.cellForItem(at: indexPath)
      if let downloadCell = cell as? BusinessDetailObjCell {
        downloadCell.item = downloadModel
      }
    }
  }
  
  func startDownloadAction(index: Int, obj: Object) {
    if !CommonFuncs.shared.isUserLoggedIn(showPopUp: true, canBeCancelled: true) {
      return
    }
    
    
    
    
    let item = obj
    
    DownloadPreference.shared.addObjToDownloads(obj: item) { [weak self] (isAlreadyExists) in
      if /isAlreadyExists {
        Toast.shared.showAlert(type: .validationFailure, message: VCLiteral.DOWNLOAD_ALREADY_EXIST.localized)
      } else {
        
        if item.objectUrl == nil {
          let components = item.mediaUrlSigned?.thumbnail?.components(separatedBy: "/")
          let fileName = (/components?.first(where: { $0.contains("thumb_") })).components(separatedBy: "?").first
          
          item.mediaUrlSigned?.downloadStatus = .PENDING
          item.mediaUrlSigned?.fileName = fileName
          item.imageUrl?.forEach({$0.downloadStatus = .PENDING})
          (self?.item as? BusinessDetail_3DObjects)?.items?[index] = item
          self?.dataSource?.items = (self?.item as? BusinessDetail_3DObjects)?.items
          self?.collectionView.reloadData()

          
          self?.downloadManager.addDownloadTask(/fileName, request: URLRequest(url: URL.init(string: /item.mediaUrlSigned?.thumbnail)!), destinationPath: MZUtility.baseFilePath)
          
          item.imageUrl?.forEach({ (image) in
            self?.downloadManager.addDownloadTask(/image.fileName, request: URLRequest(url: URL.init(string: /image.original)!), destinationPath: MZUtility.baseFilePath)
          })
        } else {
          item.objectUrl?.downloadStatus = .PENDING
          item.imageUrl?.forEach({$0.downloadStatus = .PENDING})
          
          
          (self?.item as? BusinessDetail_3DObjects)?.items?[index] = item
          self?.dataSource?.items = (self?.item as? BusinessDetail_3DObjects)?.items
          self?.collectionView.reloadData()
          self?.downloadManager.addDownloadTask(/item.objectUrl?.fileName, request: URLRequest(url: URL.init(string: /item.objectUrl?.gltf)!), destinationPath: MZUtility.baseFilePath)
          self?.downloadManager.addDownloadTask(/item.objectUrl?.thumbnailName, request: URLRequest(url: URL.init(string: /item.objectUrl?.thumbnail)!), destinationPath: MZUtility.baseFilePath)
          item.imageUrl?.forEach({ (image) in
            self?.downloadManager.addDownloadTask(/image.fileName, request: URLRequest(url: URL.init(string: /image.original)!), destinationPath: MZUtility.baseFilePath)
          })
          
        }
        
      
        EP_Other.downloadObject(objId: item._id, packageId: nil).request(success: { (_) in })
        
      }
    }
  }
  
}
