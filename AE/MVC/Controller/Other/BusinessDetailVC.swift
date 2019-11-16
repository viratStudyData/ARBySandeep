
//
//  BusinessDetailVC.swift
//  AE
//
//  Created by MAC_MINI_6 on 13/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit
import MXParallaxHeader

typealias BusinessUpdated = (_ business: Business?) -> Void

class BusinessDetailVC: BaseVC {

  @IBOutlet weak var imgHeader: UIImageView!
  @IBOutlet weak var visualEffectViewNavBar: UIVisualEffectView!
  @IBOutlet weak var visualEffectViewHeader: UIVisualEffectView!
  @IBOutlet var headerView: UIView!
  @IBOutlet weak var tableView: UITableView! {
    didSet {
      tableView.registerXIBForHeaderFooter(LineHeaderFooter.identfier)
      tableView.registerXIB(BusinessTopDetailCell.identfier)
      tableView.registerXIBForHeaderFooter(HomeSection.identfier)
      tableView.registerXIB(HorizontalCollectionCell.identfier)
      tableView.registerXIB(PackageCell.identfier)
      tableView.registerXIB(SocialLinksCell.identfier)
    }
  }
  
  private var dataSource: TableDataSource<HeaderFooterData>?
  var business: Business?
  var businessUpdated: BusinessUpdated?
  var isNavigatedViaBranches: Bool = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupTable()
    setInitialData()
    EP_Other.businessDetail(id: business?._id).request(success: { [weak self] (response) in
      self?.business = (response as? Business)
      self?.dataSource?.updateAndReload(for: .MultipleSection(items: HeaderFooterData.getBusinessDetailData(self?.business ?? Business())), .FullReload)
    }) { (error) in
      
    }
  }
  
  @IBAction func btnBackAction(_ sender: UIButton) {
    popVC()
  }
  
}

//MARK:- VCFuncs
extension BusinessDetailVC {
  private func setupTable() {
    tableView.parallaxHeader.view = headerView
    tableView.parallaxHeader.height = TableHeight.BusinessDetailTableViewHeader_MAX
    tableView.parallaxHeader.minimumHeight = TableHeight.BusinessDetailTableViewHeader_MIN
    tableView.parallaxHeader.delegate = self
    
    dataSource = TableDataSource<HeaderFooterData>(.MultipleSection(items: HeaderFooterData.getBusinessDetailData(business ?? Business(), true)), tableView)
    
    dataSource?.configureCell = { [weak self] (cell, item, indexPath, property) in
      switch /property?.cellIdentifier {
      case BusinessTopDetailCell.identfier:
        (cell as? BusinessTopDetailCell)?.isNavigatedViaBranches = self?.isNavigatedViaBranches
        (cell as? BusinessTopDetailCell)?.item = item
      case HorizontalCollectionCell.identfier:
        (cell as? HorizontalCollectionCell)?.business = self?.business
        (cell as? HorizontalCollectionCell)?.presentationType = .DataLoaded
        (cell as? HorizontalCollectionCell)?.item = item
      case PackageCell.identfier:
        (cell as? PackageCell)?.item = item
      case SocialLinksCell.identfier:
        (cell as? SocialLinksCell)?.item = item
      default:
        break
      }
    }
    
    dataSource?.configureHeaderFooter = { (section, headerFooterItem, view, isHeader) in
      (view as? HomeSection)?.business = self.business
      (view as? HomeSection)?.item = headerFooterItem
    }
    
    dataSource?.didSelectRow = { [weak self] (indexPath, item, property) in
      switch /property?.cellIdentifier {
      case PackageCell.identfier:
        let destVC = StoryboardScene.Other.PackageDetailVC.instantiate()
        destVC.business = self?.business
        destVC.package = item as? Package
        self?.pushVC(destVC)
      default:
        break
      }
    }
  }
  
  
  
  private func setInitialData() {
    imgHeader.setImageKF(business?.imageUrl?.thumbnail)
  }
}

//MARK:- MXParralaxHeaderDelegate
extension BusinessDetailVC: MXParallaxHeaderDelegate {
  func parallaxHeaderDidScroll(_ parallaxHeader: MXParallaxHeader) {
    visualEffectViewHeader.alpha = 1 - parallaxHeader.progress
    visualEffectViewNavBar.isHidden = (parallaxHeader.progress != 0.0)
    visualEffectViewHeader.isHidden = (parallaxHeader.progress == 0.0)
  }
}
