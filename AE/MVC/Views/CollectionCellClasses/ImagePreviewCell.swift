//
//  ImagePreviewCell.swift
//  AE
//
//  Created by MAC_MINI_6 on 24/06/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit
import Nuke

class ImagePreviewCell: UICollectionViewCell, ReusableCell {
  
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var imgView: UIImageView!
  @IBOutlet weak var imgPlay: UIImageView!
  @IBOutlet weak var img360: UIImageView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    scrollView.minimumZoomScale = 1.0
    scrollView.maximumZoomScale = 3
    scrollView.delegate = self
    let doubleTapGesture = UITapGestureRecognizer.init(target: self, action: #selector(handleDoubleTap(recognizer:)))
    doubleTapGesture.numberOfTapsRequired = 2
    addGestureRecognizer(doubleTapGesture)
  }
  
  var item: Any? {
    didSet {
      let itemURL = item as? ImageURL
      let mediaType = itemURL?.type ?? .IMAGE
      switch mediaType {
      case .IMAGE:
        guard let thumbURL = URL(string: /itemURL?.thumbnail) else { return }
        Nuke.loadImage(with: thumbURL, options: ImageLoadingOptions(placeholder: nil, transition: .fadeIn(duration: 0.33)) , into: imgView) { [weak self] (_, _) in
          self?.imgView.setImageKF(itemURL?.original, placeHolder: self?.imgView.image)
        }
        imgPlay.isHidden = true
        img360.isHidden = true
      case .IMAGE360:
        imgView.setImageKF(itemURL?.original)
        imgPlay.isHidden = false
        img360.isHidden = false
        imgPlay.addTapGestureRecognizer {
          let destVC = StoryboardScene.Other.Image360VC.instantiate()
          destVC.url = URL(string: /itemURL?.original)
          UIApplication.topVC()?.presentVC(destVC)
        }
      case .VIDEO:
        imgView.setImageKF(itemURL?.thumbnail)
        imgPlay.isHidden = false
        img360.isHidden = true
        imgPlay.addTapGestureRecognizer {
          UIApplication.topVC()?.playVideo(URL(string: /itemURL?.original)!)
        }
      case .VIDEO360:
        imgPlay.addTapGestureRecognizer {
          let destVC = StoryboardScene.Other.Video360VC.instantiate()
          destVC.urlString = itemURL?.original
          UIApplication.topVC()?.presentVC(destVC)
        }
        imgView.setImageKF(itemURL?.thumbnail)
        imgPlay.isHidden = false
        img360.isHidden = false
      case .OBJECT:
        break
      }
    }
   
  }
  
  //Mark : handling double tap gesture
  @objc func handleDoubleTap(recognizer: UITapGestureRecognizer) {
    if (item as? ImageURL)?.type ?? .IMAGE != .IMAGE {
      return
    }
    if scrollView.zoomScale == 1 {
      scrollView.zoom(to: zoomRectForScale(scale: scrollView.maximumZoomScale), animated: true)
    } else {
      scrollView.setZoomScale(1, animated: true)
    }
  }
  
  //Mark : For focusing to particular area where user double clicks
  func zoomRectForScale(scale: CGFloat) -> CGRect {
    let centerOfScreen = CGPoint(x: ScreenSize.SCREEN_WIDTH / 2.0, y: ScreenSize.SCREEN_HEIGHT / 2.0)
    var zoomRect = CGRect.zero

//    zoomRect.size.height = imgView.frame.size.height / scale
//    zoomRect.size.width  = imgView.frame.size.width  / scale
    zoomRect.size.height = imgView.contentSize().height / scale
    zoomRect.size.width  = imgView.contentSize().width  / scale
    let newCenter = imgView.convert(centerOfScreen, from: scrollView)
    zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
    zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
    return zoomRect
  }
  
}

//MARK:- UIScrollView Delegates
extension ImagePreviewCell: UIScrollViewDelegate {
  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    if (item as? ImageURL)?.type ?? .IMAGE == .IMAGE {
      return imgView
    } else {
      return nil
    }
  }
}

extension UIImageView {
  func contentSize() -> CGSize {
    if let myImage = self.image {
      let myImageWidth = myImage.size.width
      let myImageHeight = myImage.size.height
      let myViewWidth = self.frame.size.width
      
      let ratio = myViewWidth/myImageWidth
      let scaledHeight = myImageHeight * ratio
      
      return CGSize(width: myViewWidth, height: scaledHeight)
    }
    
    return CGSize(width: -1.0, height: -1.0)
  }
}
