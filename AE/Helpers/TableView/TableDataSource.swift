//
//  File.swift
//  AE
//
//  Created by MAC_MINI_6 on 08/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

enum InfiniteScrollStatus {
  case FinishLoading // stop infinite loading and pull to refresh
  case LoadingContent // handled automatically no need to setup assign Viewcontroller
  case NoContentAnyMore // no more paging
}

enum TableType<T : HeaderFooterDataProvider, U> {
  case SingleListing(items: [U], identifier: String, height: CGFloat)
  case MultipleSection(items: [T])
}

enum UpdateType<T: HeaderFooterDataProvider, U> {
  case SingleListing(items: [U])
  case MultipleSection(items: [T])
}

enum ReloadType {
  case FullReload
  case ReloadSectionAt(indexSet: IndexSet, animation: UITableView.RowAnimation)
  case Reload(indexPaths: [IndexPath], animation: UITableView.RowAnimation)
  case ReloadSectionTitles
  case None
  case DeleteRowsAt(indexPaths: [IndexPath], animation: UITableView.RowAnimation)
}

enum ScrollDirection {
  case Up
  case Down
}

extension UITableView {
  func reloadData(success: (() -> Void)?) {
    CATransaction.begin()
    CATransaction.setCompletionBlock {
      success?()
    }
    reloadData()
    CATransaction.commit()
  }
}

class TableDataSource<T : HeaderFooterDataProvider>: NSObject, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
  
  
  typealias DidSelectedRow = (_ indexPath : IndexPath, _ item: Any?, _ property: HeaderFooterValues?) -> Void
  typealias ViewForHeaderFooterInSection = (_ section : Int, _ headerFooterItem: T, _ view: UIView, _ isHeader: Bool) -> Void
  typealias ListCellConfigureBlock = (_ cell : UITableViewCell , _ item : Any?, _ indexpath: IndexPath, _ property: HeaderFooterValues?) -> ()
  typealias DirectionForScroll = (_ direction: ScrollDirection) -> Void
  typealias InfiniteScroll = () -> Void
  typealias Pulled = () -> Void

  private var tableView: UITableView?
  private var items = Array<T>()
  private var tableType: TableType<T, Any>?
  private var identifier: String?
  private var height: CGFloat?
  private var infiniteLoadingStatus: InfiniteScrollStatus = .FinishLoading
  private lazy var refreshControl: UIRefreshControl = {
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: UIControl.Event.valueChanged)
    refreshControl.tintColor = Color.gradient2.value
    
    return refreshControl
  }()
  private var isReloadingFinished = false
  
  public var didSelectRow: DidSelectedRow?
  public var configureHeaderFooter: ViewForHeaderFooterInSection?
  public var configureCell: ListCellConfigureBlock?
  public var scrollDirection: DirectionForScroll?
  public var addInfiniteScrolling: InfiniteScroll?
  public var addPullToRefresh: Pulled?
  
  init(_ _type: TableType<T, Any>, _ _tableView: UITableView, _ withPullToRefresh: Bool? = false) {
    super.init()
    tableType = _type
    tableView = _tableView
    switch _type {
    case .SingleListing(let _items, let _identifier, let _height):
      identifier = _identifier
      height = _height
      items = HeaderFooterData.getSingleSectionItems(items: _items, id: _identifier, height: _height) as! [T]
    case .MultipleSection(let _items):
      items = _items
    }
    if withPullToRefresh ?? false {
      tableView?.addSubview(refreshControl)
    }
    tableView?.delegate = self
    tableView?.dataSource = self
    tableView?.reloadData(success: { [weak self] in
      self?.isReloadingFinished = true
    })
  }
  
  public func updateAndReload(for type: UpdateType<T, Any>, _ reloadType: ReloadType) {
    isReloadingFinished = false
    switch type {
    case .SingleListing(let _items):
      items = HeaderFooterData.getSingleSectionItems(items: _items, id: identifier ?? "", height: height ?? 0.0) as! [T]
    case .MultipleSection(let _items):
      items = _items
    }
    reloadTableView(type: reloadType)
  }
  
  public func stopInfiniteLoading(_ status: InfiniteScrollStatus) {
    infiniteLoadingStatus = status
    refreshControl.endRefreshing()
  }
  
  public func refreshProgrammatically() {
    infiniteLoadingStatus = .LoadingContent
    refreshControl.beginRefreshing()
    let offsetPoint = CGPoint.init(x: 0, y: -refreshControl.frame.size.height)
    tableView?.setContentOffset(offsetPoint, animated: true)
    addPullToRefresh?()
  }
  
  @objc private func handleRefresh(_ refreshControl: UIRefreshControl) {
    infiniteLoadingStatus = .LoadingContent
    addPullToRefresh?()
  }
 
  private func reloadTableView(type: ReloadType) {
    switch type {
    case .FullReload:
      tableView?.reloadData(success: { [weak self] in
        self?.isReloadingFinished = true
      })
    case .Reload(let indexPaths, let animation):
      tableView?.reloadRows(at: indexPaths, with: animation)
      isReloadingFinished = true
    case .ReloadSectionAt(let indexSet, let animation):
      tableView?.reloadSections(indexSet, with: animation)
      isReloadingFinished = true
    case .ReloadSectionTitles:
      tableView?.reloadSectionIndexTitles()
      isReloadingFinished = true
    case .None:
      isReloadingFinished = true
    case .DeleteRowsAt(let indexPaths, let animation):
      tableView?.beginUpdates()
      tableView?.deleteRows(at: indexPaths, with: animation)
      tableView?.endUpdates()
      tableView?.reloadData(success: { [weak self] in
        self?.isReloadingFinished = true
      })
    }
  }
  
  internal func numberOfSections(in tableView: UITableView) -> Int {
    return items.count
  }
  
  internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items[section].items?.count ?? 0
  }
  
  internal func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let item = items[section]
    guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: item.property?.headerIdentifier ?? "") else {
      return nil
    }
    configureHeaderFooter?(section, item, headerView, true)
    return headerView
  }
  
  internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let property = items[indexPath.section].property
    let cell = tableView.dequeueReusableCell(withIdentifier: property?.cellIdentifier ?? "", for: indexPath)
    configureCell?(cell, items[indexPath.section].items?[indexPath.row], indexPath, property)
    return cell
  }
  
  internal func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    let item = items[section]
    guard let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: item.property?.footerIdentifier ?? "") else {
      return nil
    }
    configureHeaderFooter?(section, item, footerView, false)
    return footerView
  }
  
  internal func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return items[section].property?.headerHeight ?? 0.0001
  }
  
  internal func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return items[section].property?.footerHeight ?? 0.0001
  }
  
  internal func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return items[indexPath.section].property?.cellHeight ?? UITableView.automaticDimension
  }
  
  internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    didSelectRow?(indexPath, items[indexPath.section].items?[indexPath.row], items[indexPath.section].property)
  }
  
  internal func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    switch velocity {
    case _ where velocity.y < 0:
      // swipes from top to bottom of screen -> down
      scrollDirection?(.Down)
    case _ where velocity.y > 0:
      // swipes from bottom to top of screen -> up
      scrollDirection?(.Up)
    default: break
    }
  }
  
  internal func scrollViewDidScroll(_ scrollView: UIScrollView) {
    
    if !isReloadingFinished {
      return
    }
    
    if refreshControl.isRefreshing {
      return
    }
    
    switch infiniteLoadingStatus {
    case .LoadingContent, .NoContentAnyMore:
      return
    case .FinishLoading:
      // calculates where the user is in the y-axis
      let offsetY = scrollView.contentOffset.y
      let contentHeight = scrollView.contentSize.height
      
      if offsetY > contentHeight - scrollView.frame.size.height {
        infiniteLoadingStatus = .LoadingContent
        addInfiniteScrolling?()
      }
    }
    
  }
  
}
