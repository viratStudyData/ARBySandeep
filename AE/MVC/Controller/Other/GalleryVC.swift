//
//  GalleryVC.swift
//  AE
//
//  Created by MAC_MINI_6 on 27/05/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit
import KVSpinnerView

class GalleryVC: BaseVC {
  
  @IBOutlet weak var navBar: UIView!
  @IBOutlet weak var btnBack: UIButton!
  @IBOutlet weak var lblTitle: UILabel!
  @IBOutlet weak var lblSubTitle: UILabel!
  @IBOutlet weak var titleTopConstraint: NSLayoutConstraint! // 44 or 0
  @IBOutlet weak var collectionViewTop: NSLayoutConstraint! // 8 / 0
  @IBOutlet weak var collectionView: UICollectionView!
  
  var business: Business?
  private var dataSource: CollectionDataSource?
  private var items: [Gallery]? {
    didSet {
      dataSource?.items = items
      collectionView.reloadData()
    }
  }
  private var pageNo = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    lblSubTitle.text = String(format: VCLiteral.AR_PACKAGE_BY.localized, arguments: [/business?.name])
    collectionViewSetup()
  }

  @IBAction func btnBackAction(_ sender: UIButton) {
    popVC()
  }
}

//MARK:- VCFuncs
extension GalleryVC {
  
  private func getGalleryAPI() {
    EP_Other.getGallery(businessId: business?._id, pageNo: String(pageNo)).request(success: { [weak self] (response) in
      let newItems = (response as? [Gallery]) ?? []
      self?.dataSource?.stopInfiniteLoading(newItems.count == 0 ? .NoContentAnyMore : .FinishLoading)
      self?.items = (self?.items ?? []) + newItems
    }) { [weak self] (error) in
      if /self?.pageNo != 0 {
        self?.pageNo = /self?.pageNo - 1
      }
      self?.dataSource?.stopInfiniteLoading(.FinishLoading)
    }
  }
  
  private func collectionViewSetup() {
    collectionView.registerXIB(ImageCell.identfier)
    
    dataSource = CollectionDataSource(items, ImageCell.identfier, collectionView, CollectionSize.GalleryVCSize, UIEdgeInsets.init(top: 8, left: 24, bottom: 24, right: 24), 8.0, 8.0)
    
    dataSource?.configureCell = { (cell, item, indexPath) in
      (cell as? ImageCell)?.item = item
    }
    
    dataSource?.didSelectItem = { [weak self] (indexPath, item) in
      switch self?.items?[indexPath.item].fileUrl?.type ?? .IMAGE {
      case .IMAGE:
        let images = self?.items?.map({$0.fileUrl!})
        let destVC = StoryboardScene.Other.MediaPreviewVC.instantiate()
        destVC.item = (images, indexPath.item)
        self?.pushVC(destVC)
      case .IMAGE360:
        let destVC = StoryboardScene.Other.Image360VC.instantiate()
        destVC.url = URL(string: /self?.items?[indexPath.item].fileUrl?.original)
        self?.presentVC(destVC)
      case .VIDEO360:
        KVSpinnerView.show()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { [weak self] in
          let destVC = StoryboardScene.Other.Video360VC.instantiate()
          destVC.urlString = /self?.items?[indexPath.item].fileUrl?.original
          self?.presentVC(destVC)
        })
      case .VIDEO:
        self?.playVideo(URL(string: /self?.items?[indexPath.item].fileUrl?.original))
      case .OBJECT:
        break
      }
      
     
    }
    
    dataSource?.scrollDirection = { [weak self] (direction) in
      if direction == .Down {
        self?.navBar.isHidden = true
      }
      self?.navigationBarAnimationHandling(direction: direction)
    }
    
    dataSource?.addPullToRefreshVertically({ [weak self] in
      self?.pageNo = 0
      self?.items = []
      self?.collectionView.reloadData()
      self?.getGalleryAPI()
    })
    
    dataSource?.addInfiniteScrollVertically = { [weak self] in
      self?.pageNo = /self?.pageNo + 1
      self?.getGalleryAPI()
    }
    
    dataSource?.refreshProgrammatically()
  }
  
  //MARK:- Handling Animation for navigation bar
  private func navigationBarAnimationHandling(direction: ScrollDirection) {
    collectionViewTop.constant = direction == .Up ? 0 : 8.0
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
