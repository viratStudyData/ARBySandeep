//
//  FollowingVC.swift
//  AE
//
//  Created by MAC_MINI_6 on 29/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

class FollowingVC: BaseVC {
  
  @IBOutlet weak var lblTitle: UILabel!
  @IBOutlet weak var navBar: UIView!
  @IBOutlet weak var titleTopConstraint: NSLayoutConstraint! // 44 or 0
  @IBOutlet weak var tableView: UITableView! {
    didSet {
      tableView.registerXIB(FollowBusinessTVCell.identfier)
    }
  }
  @IBOutlet weak var tfSearch: UITextField!
  @IBOutlet weak var lblNoData: UILabel!
  
  private var dataSource: TableDataSource<HeaderFooterData>?
  private var items: [Business]?
  private var pageNo = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableViewinit()
  }
  
  @IBAction func btnBackAction(_ sender: UIButton) {
    popVC()
  }
  
}

//MARK:- VCFuncs
extension FollowingVC {
  
  private func tableViewinit() {
    dataSource = TableDataSource<HeaderFooterData>(TableType.SingleListing(items: items ?? [], identifier: FollowBusinessTVCell.identfier, height: UITableView.automaticDimension), tableView, true)
    
    dataSource?.configureCell = { (cell, item, indexPath, property) in
      (cell as? FollowBusinessTVCell)?.item = item
      (cell as? FollowBusinessTVCell)?.didTapFollowUnfollow = { [weak self] in
        self?.followUnfollowAPI(item: item as? Business, indexPath: indexPath)
      }
    }
    
    dataSource?.scrollDirection = { [weak self] (direction) in
      if direction == .Down {
        self?.navBar.isHidden = true
      }
      self?.navigationBarAnimationHandling(direction: direction)
    }
    
    dataSource?.didSelectRow = { [weak self] (indexPath, item, _ ) in
      let destVC = StoryboardScene.Other.BusinessDetailVC.instantiate()
      destVC.business = item as? Business
      destVC.businessUpdated = { (business) in
        self?.updateDataOfVC(business: business)
      }
      self?.pushVC(destVC)
    }
    
    dataSource?.addInfiniteScrolling = { [weak self] in
      self?.pageNo = /self?.pageNo + 1
      self?.getFollowingBusinessesAPI()
    }
    
    dataSource?.addPullToRefresh = { [weak self] in
      self?.pageNo = 0
      self?.items = []
      self?.dataSource?.updateAndReload(for: .SingleListing(items: self?.items ?? []), .FullReload)
      self?.getFollowingBusinessesAPI()
    }
    
    dataSource?.refreshProgrammatically()
  }
  
  private func updateDataOfVC(business: Business?) {
    let index: Int = /items?.firstIndex(where: { $0 == business})
    if /business?.isFollowing == false {
      items?.remove(at: index)
      dataSource?.updateAndReload(for: .SingleListing(items: items ?? []), .DeleteRowsAt(indexPaths: [IndexPath(row: index, section: 0)], animation: .right))
    } else if !(/items?.contains(business ?? Business())) {
      items?.append(business ?? Business())
      dataSource?.updateAndReload(for: .SingleListing(items: items ?? []), .FullReload)
    }
  }
  
  private func followUnfollowAPI(item: Business?, indexPath: IndexPath) {
    let unfollowVC = StoryboardScene.PopUp.UnfollowPopUpVC.instantiate()
    unfollowVC.business = item
    unfollowVC.didTapYes = { [weak self] in
      EP_Other.followUnfollowBusiness(id: item?._id, action: item?.isFollowing?.actionToAPI).request(success: { (_) in
      })
      self?.items?.remove(at: indexPath.row)
      self?.dataSource?.updateAndReload(for: .SingleListing(items: self?.items ?? []), .DeleteRowsAt(indexPaths: [indexPath], animation: .right))
      UserPreference.shared.updateFollowingCount(false)
      self?.lblNoData.isHidden = /self?.items?.count != 0
    }
    presentPopUp(unfollowVC)
  }
  
  private func getFollowingBusinessesAPI() {
    EP_Other.followedBusinesses(pageNo: String(pageNo)).request(success: { [weak self] (response) in
      let newItems = (response as? BusineesPageObject)?.data ?? []
      self?.dataSource?.stopInfiniteLoading(newItems.count == 0 ? .NoContentAnyMore : .FinishLoading)
      self?.items = (self?.items ?? []) + newItems
      self?.lblNoData.isHidden = /self?.items?.count != 0
      self?.dataSource?.updateAndReload(for: .SingleListing(items: self?.items ?? []), .FullReload)
    }) { [weak self] (error) in
      self?.dataSource?.stopInfiniteLoading(.FinishLoading)
      if /self?.pageNo > 0 {
        self?.pageNo = /self?.pageNo - 1
      }
    }
  }
  
  //MARK:- Handling Animation for navigation bar
  private func navigationBarAnimationHandling(direction: ScrollDirection) {
    titleTopConstraint.constant = direction == .Up ? 0 : 44
    UIView.transition(with: lblTitle, duration: 0.2, options: .curveLinear, animations: {
      self.lblTitle.textAlignment = direction == .Up ? .center : .left
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
