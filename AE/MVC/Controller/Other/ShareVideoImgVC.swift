//
//  ShareVideoImgVC.swift
//  AE
//
//  Created by MAC_MINI_6 on 12/06/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

enum ShareItemType {
  case video(localURL: URL)
  case image(uiImage: UIImage)
  
  var messageType: MESSAGE_TYPE {
    switch self {
    case .image(_):
      return .IMAGE
    case .video(_):
      return .VIDEO
    }
  }
}

extension UIImage {
  convenience init(view: UIView) {
    UIGraphicsBeginImageContext(view.frame.size)
    view.layer.render(in:UIGraphicsGetCurrentContext()!)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    self.init(cgImage: image!.cgImage!)
    
    
  }
  
  func flipImageLeftRight() -> UIImage? {
//
//    UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
//    let context = UIGraphicsGetCurrentContext()!
//    context.translateBy(x: self.size.width, y: self.size.height)
//    context.scaleBy(x: -self.scale, y: -self.scale)
//
//    context.draw(self.cgImage!, in: CGRect(origin:CGPoint.zero, size: self.size))
//
//    let newImage = UIGraphicsGetImageFromCurrentImageContext()
//
//    UIGraphicsEndImageContext()
    return UIImage.init(cgImage: self.cgImage!, scale: self.scale, orientation: .leftMirrored)
//    return UIImage(CGImage: self.CGImage!, scale: self.scale, orientation: .leftMirrored)
//    return newImage
  }
}

class ShareVideoImgVC: BaseVC {

  @IBOutlet weak var imgView: UIImageView!
  @IBOutlet weak var imgPlay: UIImageView!
  @IBOutlet weak var imgSuperView: UIView!
  @IBOutlet weak var collectionView: UICollectionView!
  
  var shareItem: ShareItemType?
  private var dataSource: CollectionDataSource?
  var imgToAppend: UIImage?
  private var localVideoURL: URL?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    initialSetup()
    addTapGestureOnPlay()
    collectionSetup()
  }
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
  
  @IBAction func btnAction(_ sender: UIButton) {
    switch sender.tag {
    case 0: // Close
      popVC(animated: false)
    case 1: // Send
      if !CommonFuncs.shared.isUserLoggedIn(showPopUp: true, canBeCancelled: true) {
        return
      }
      
      let destVC = StoryboardScene.Other.ShareWithVC.instantiate()
      switch shareItem! {
      case .image(_):
        destVC.shareItem = ShareItemType.image(uiImage: UIImage(view: imgSuperView))
        pushVC(destVC)
      case .video(_):
        destVC.shareItem = shareItem
        pushVC(destVC)
      }
    case 2: // Share
      switch shareItem! {
      case .image(_):
        let image = UIImage(view: imgSuperView)
        let acitivityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        presentVC(acitivityVC)
      case .video(let url):
        let acitivityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        presentVC(acitivityVC)
      }
    default:
      break
    }
  }
  
}

//MARK:- VCFuncs
extension ShareVideoImgVC {
  
  func collectionSetup() {
    var images = [UIImage]()
    
    if let image = imgToAppend {
      images = [image]
    }
    dataSource = CollectionDataSource.init(images, OverlayImageCell.identfier, collectionView, CGSize.init(width: ScreenSize.SCREEN_WIDTH, height: ScreenSize.SCREEN_HEIGHT), UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0), 0, 0)
    
    dataSource?.configureCell = { (cell, item, indexPath) in
      (cell as? OverlayImageCell)?.item = item
    }
    
  
  }
  
  func initialSetup() {
    switch shareItem! {
    case .image(let uiImage):
      imgView.setImageKF(uiImage)
      imgPlay.isHidden = true
      collectionView.isHidden = false
    case .video(let localURL):
      collectionView.isHidden = true
      localVideoURL = localURL
      do {
        let _ = try Data(contentsOf: localURL)
        imgView.image = mediaPicker.generateThumbnailfrom(url: localURL)
      } catch {
        print(error.localizedDescription)
      }
      imgPlay.isHidden = false
    }
  }
  
  func addTapGestureOnPlay() {
    imgPlay.addTapGestureRecognizer { [weak self] in
      self?.playVideo(self?.localVideoURL)
    }
  }
}
