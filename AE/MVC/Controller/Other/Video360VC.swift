//
//  Video360VC.swift
//  AE
//
//  Created by MAC_MINI_6 on 24/06/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit
import Swifty360Player
import AVKit
import KVSpinnerView

class Video360VC: BaseVC {
  
  @IBOutlet weak var btnCancel: UIButton!
  @IBOutlet weak var controlsView: UIVisualEffectView!
  @IBOutlet weak var progressBar: UIProgressView!
  @IBOutlet weak var btnPlay: UIButton!
  @IBOutlet var swift360View: Swifty360View!
  @IBOutlet weak var indicator: UIActivityIndicatorView!
  
  var urlString: String?
  private var player: AVPlayer?
  private var observer: Any?
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    guard let videoURL = URL(string: /urlString) else { return }
    player = AVPlayer(url: videoURL)
    
    swift360View.setup(player: player!, motionManager: Swifty360MotionManager.shared)
    player?.play()
    view.bringSubviewToFront(btnCancel)
    view.bringSubviewToFront(controlsView)
    view.bringSubviewToFront(indicator)
    indicator.startAnimating()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(true)
    
    KVSpinnerView.dismiss()
    player?.play()
    addPeriodicTimeObserver(player: player)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(true)
    player?.pause()
    guard let timeObserver = observer else { return }
    player?.removeTimeObserver(timeObserver)
    observer = nil
  }
  
  @IBAction func btnCancelAction(_ sender: UIButton) {
    dismissVC()
  }
  
  
  @IBAction func btnControls(_ sender: UIButton) {
    switch sender.tag {
    case 0: //Backward 15 Sec
      doBackwardJump()
    case 1: //Play Pause
      if player?.timeControlStatus == .playing {
        player?.pause()
        sender.setImage(#imageLiteral(resourceName: "ic_play-360"), for: .normal)
      } else {
        player?.play()
        sender.setImage(#imageLiteral(resourceName: "ic_pause"), for: .normal)
      }
    case 2: //Forward 15 Sec
      doForwardJump()
    default:
      break
    }
  }
}

//MARK:- VCFuncs
extension Video360VC {
  private func addPeriodicTimeObserver(player: AVPlayer?) {
    // Invoke callback every half second
    let interval = CMTime(seconds: 0.5,
                          preferredTimescale: CMTimeScale(NSEC_PER_SEC))
    // Queue on which to invoke the callback
    let mainQueue = DispatchQueue.main
    // Add time observer
    observer = player?.addPeriodicTimeObserver(forInterval: interval, queue: mainQueue) { [weak self] time in
      
      if self?.player?.currentItem?.status == AVPlayerItem.Status.readyToPlay {
        
        if let isPlaybackLikelyToKeepUp = self?.player?.currentItem?.isPlaybackLikelyToKeepUp {
          isPlaybackLikelyToKeepUp ? self?.indicator.stopAnimating() : self?.indicator.startAnimating()
          
          //do what ever you want with isPlaybackLikelyToKeepUp value, for example, show or hide a activity indicator.
        }
      }
      
      let currentSeconds = CMTimeGetSeconds(time)
      guard let duration = player?.currentItem?.duration else { return }
      let totalSeconds = CMTimeGetSeconds(duration)
      let progress: Float = Float(currentSeconds/totalSeconds)
      self?.progressBar.setProgress(progress, animated: true)
      print(progress)
    }
  }
  
  private func doForwardJump() {
    guard let duration  = player?.currentItem?.duration else{
      return
    }
    let playerCurrentTime = CMTimeGetSeconds(player?.currentTime() ?? CMTime())
    let newTime = playerCurrentTime + 15.0
    
    if newTime < CMTimeGetSeconds(duration) {
      
      let time2: CMTime = CMTime(value: Int64(newTime * 1000 as Float64), timescale: 1000)
      player?.seek(to: time2)
    }
  }
  
  private func doBackwardJump() {
    let playerCurrentTime = CMTimeGetSeconds(player?.currentTime() ?? CMTime())
    var newTime = playerCurrentTime - 15.0
    
    if newTime < 0 {
      newTime = 0
    }
    let time2: CMTime = CMTime(value: Int64(newTime * 1000 as Float64), timescale: 1000)
    
    player?.seek(to: time2)
    
  }
}
