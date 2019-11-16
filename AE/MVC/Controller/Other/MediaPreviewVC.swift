//
//  MediaPreviewVC.swift
//  AE
//
//  Created by MAC_MINI_6 on 24/06/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

class MediaPreviewVC: BaseVC {
  
  @IBOutlet weak var collectionView: UICollectionView!
  
  var item: (images: [ImageURL]?, index: Int)?
  private var dataSource: CollectionDataSource?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    collectionSetup()
  }
  
  // Detect Device orientation changes
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    let width = UIDevice.current.orientation.isLandscape ? ScreenSize.SCREEN_HEIGHT : ScreenSize.SCREEN_WIDTH
    let height = UIDevice.current.orientation.isLandscape ? ScreenSize.SCREEN_WIDTH : ScreenSize.SCREEN_HEIGHT
    dataSource?.size = CGSize(width: width, height: height)
    collectionView.performBatchUpdates({ [weak self] in
      self?.setUpCurrentIndexChange(willSetup: false)
      self?.collectionView.reloadData()
    }) { [weak self] (isCompleted) in
      if isCompleted {
        self?.collectionView.scrollToItem(at: IndexPath.init(row: /self?.item?.index, section: 0), at: .centeredHorizontally, animated: false)
        self?.setUpCurrentIndexChange(willSetup: true)
      }
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(true)
    setUpCurrentIndexChange(willSetup: true)
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidAppear(true)
    UIDevice.current.setValue(UIInterfaceOrientationMask.portrait.rawValue, forKey: "orientation")
  }
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
  
  @IBAction func btnBackAction(_ sender: UIButton) {
    popVC()
  }
  
}

//MARK:- VCFuncs
extension MediaPreviewVC {
  
  func setUpCurrentIndexChange(willSetup: Bool) {
    willSetup ? ( dataSource?.didChangeCurrentIndex = { [weak self] (indexPath) in
      self?.item?.index = indexPath.item
      } ) : ( dataSource?.didChangeCurrentIndex = nil )
  }
  
  func collectionSetup() {
    dataSource = CollectionDataSource(item?.images, ImagePreviewCell.identfier, collectionView, CGSize(width: ScreenSize.SCREEN_WIDTH, height: ScreenSize.SCREEN_HEIGHT) , UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0), 0, 0)
    
    dataSource?.configureCell = { (cell, item, indexPath) in
      (cell as? ImagePreviewCell)?.item = item
    }
    
    collectionView.performBatchUpdates({ [weak self] in
      self?.collectionView.reloadData()
    }) { [weak self] (isCompleted) in
      if isCompleted {
        self?.collectionView.scrollToItem(at: IndexPath.init(row: /self?.item?.index, section: 0), at: .centeredHorizontally, animated: false)
      }
    }
    
    // To use interactive pop gesture recognizer with collectionview horizontal scroll
    guard let interactiveGesture = navigationController?.interactivePopGestureRecognizer else {
      return
    }
    collectionView.panGestureRecognizer.require(toFail: interactiveGesture)
    
  }
  
}
