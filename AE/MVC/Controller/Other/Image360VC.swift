//
//  Image360VC.swift
//  AE
//
//  Created by MAC_MINI_6 on 05/07/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit
import CTPanoramaView
import Nuke

class Image360VC: BaseVC {
  
  @IBOutlet weak var panoramaView: CTPanoramaView!
  @IBOutlet weak var indicator: UIActivityIndicatorView!
  
  var url: URL?
  var imageTask: ImageTask?
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    indicator.startAnimating()
    panoramaView.controlMethod = .motion
//    panoramaView.controlMethod = .touch
    imageTask = ImagePipeline.shared.loadImage(with: ImageRequest(url: url!), progress: { (response, completed, total) in
      print(completed, total)
    }) { [weak self] (response, error) in
      self?.indicator.stopAnimating()
      self?.indicator.isHidden = true
      self?.panoramaView.image = response?.image
    }
  }
  
  
  @IBAction func btnCancelAction(_ sender: UIButton) {
    imageTask?.cancel()
    dismissVC()
  }
}
