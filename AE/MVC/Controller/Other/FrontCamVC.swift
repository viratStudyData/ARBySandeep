//
//  FrontCamVC.swift
//  AE
//
//  Created by MAC_MINI_6 on 05/07/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit
import AVFoundation

enum CaptureStatus: Int {
  case Capture
  case None
  case StartRecording
  case EndRecording
}

class FrontCamVC: BaseVC {
  
  @IBOutlet weak var imgViewCamera: UIImageView!
  @IBOutlet weak var btnShutter: UIButton!
  @IBOutlet weak var collectionView: UICollectionView!
  
  private var session = AVCaptureSession()
  private var previewLayer: CALayer?
  private var captureDevice: AVCaptureDevice?
  private var status: CaptureStatus = .None
  private let imageOutput = AVCaptureVideoDataOutput()
  private var videoFileOutput = AVCaptureMovieFileOutput()
  var dataSource: CollectionDataSource?
  private var filters: [Filter]?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    btnShutter.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(singleTap(gesture:))))
    btnShutter.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longPress(gesture:))))
    collectionView.isUserInteractionEnabled = true
    let tap = UITapGestureRecognizer.init(target: self, action: #selector(doubleTap(sender:)))
    tap.numberOfTapsRequired = 2
    collectionView.addGestureRecognizer(tap)
    collectionSetup()
    EP_Other.nearByBusinessFilters.request(success: { [weak self] (response) in
      var newItems = response as? [Filter]
      newItems?.insert(Filter(), at: 0)
      self?.dataSource?.items = newItems
      self?.collectionView.reloadData()
    }) { (_) in }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    prepareCamera()
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(true)
    stopCaptureSession()
  }
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
  
  @IBAction func btnCancelAction(_ sender: UIButton) {
    popVC()
  }
  
    @objc func doubleTap(sender: UITapGestureRecognizer) {
        let destVC = StoryboardScene.Other.CameraVC.instantiate()
        destVC.isScanning = true
        navigationController?.replaceTopViewController(with: destVC, animated: false)
    }
  
  //Image Capture actions
  @objc func singleTap(gesture: UITapGestureRecognizer) {
    status = .Capture
  }
  
  //Video Recording actions
  @objc func longPress(gesture: UILongPressGestureRecognizer) {
//    switch gesture.state {
//    case .began:
//      btnShutter.setImage(#imageLiteral(resourceName: "ic_record"), for: .normal)
//      startVideoRecording()
//    case .ended:
//      btnShutter.setImage(#imageLiteral(resourceName: "ic_capture"), for: .normal)
//      stopVideoRecording()
//    default:
//      break
//    }
  }
  
  func collectionSetup() {
//    let images = [UIImage(), #imageLiteral(resourceName: "Lens")]
    
    dataSource = CollectionDataSource.init(filters, OverlayImageCell.identfier, collectionView, CGSize.init(width: ScreenSize.SCREEN_WIDTH, height: ScreenSize.SCREEN_HEIGHT), UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0), 0, 0)
    
    dataSource?.configureCell = { (cell, item, indexPath) in
      (cell as? OverlayImageCell)?.item = item
    }
  }
  
  
  private func prepareCamera() {
    
    let availableDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera, .builtInTrueDepthCamera], mediaType: AVMediaType.video, position: .front).devices
    captureDevice = availableDevices.first
    
    if /captureDevice?.supportsSessionPreset(.hd1920x1080) {
      session.sessionPreset = AVCaptureSession.Preset.hd1920x1080
    } else {
      session.sessionPreset = AVCaptureSession.Preset.hd1280x720
    }
    
    availableDevices.count > 0 ? beginSession() : ()
  }

  
  private func beginSession() {
    (imgViewCamera.layer.sublayers)?.forEach {
      $0.removeFromSuperlayer()
    }
    
    do {
      let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice!)
      session.addInput(captureDeviceInput)
    } catch {
      print(error.localizedDescription)
    }
    
    previewLayer = AVCaptureVideoPreviewLayer(session: session)
    previewLayer?.contentsGravity = .bottom

    imgViewCamera.layer.addSublayer(previewLayer!)
    previewLayer?.frame = CGRect(x: 0, y: 0, width: ScreenSize.SCREEN_WIDTH, height: ScreenSize.SCREEN_HEIGHT)
    session.startRunning()
      
    imageOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_32BGRA)] as [String : Any]
    imageOutput.alwaysDiscardsLateVideoFrames = true
    if session.canAddOutput(imageOutput) {
      session.addOutput(imageOutput)
    }
    
    session.commitConfiguration()
    
    let queue = DispatchQueue(label: "com.augmentedExperience.app.frontCam")
    imageOutput.setSampleBufferDelegate(self, queue: queue)
  }
  
  private func getImageFromSampleBuffer(buffer: CMSampleBuffer) -> UIImage? {
    if let pixelBuffer = CMSampleBufferGetImageBuffer(buffer) {
      let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
      let context = CIContext()
      let imageRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
      if let image = context.createCGImage(ciImage, from: imageRect) {
        return UIImage(cgImage: image, scale: UIScreen.main.scale, orientation: .right)
      }
    }
    return nil
  }
  
  private func stopCaptureSession() {
    session.stopRunning()
    if let inputs = session.inputs as? [AVCaptureInput] {
      inputs.forEach {
        self.session.removeInput($0)
      }
    }
  }
  
  private func startVideoRecording() {
    let recordingDelegate: AVCaptureFileOutputRecordingDelegate? = self
    session.addOutput(videoFileOutput)
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let filePath = documentsURL.appendingPathComponent("temp.mp4")
    
    videoFileOutput.startRecording(to: filePath, recordingDelegate: recordingDelegate!)

  }
  
  private func stopVideoRecording() {
    videoFileOutput.stopRecording()
    session.removeOutput(videoFileOutput)
  }
}

//MARK:- AVCaptureVideoDataOutput Delegate
extension FrontCamVC: AVCaptureVideoDataOutputSampleBufferDelegate {
  
  func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    switch status {
    case .Capture: // Capture a photo
      if let capturedImage = getImageFromSampleBuffer(buffer: sampleBuffer) {
        DispatchQueue.main.async {
            let destVC = StoryboardScene.Other.ShareVideoImgVC.instantiate()
            let index = /self.collectionView.indexPathsForVisibleItems.first?.item
            destVC.imgToAppend = (self.collectionView.cellForItem(at: IndexPath.init(item: index, section: 0)) as? OverlayImageCell)?.imgView.image
            destVC.shareItem = ShareItemType.image(uiImage: capturedImage.flipImageLeftRight() ?? UIImage())
            self.pushVC(destVC, animated: false)
        }
      }
    case .StartRecording: // Start recording
      break
    case .EndRecording: //End Recording
      break
    case .None:
      break
    }
    status = .None
  }
  
}

//MARK:- Video Recording Delegates
extension FrontCamVC: AVCaptureFileOutputRecordingDelegate {
  
  func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
    self.playVideo(outputFileURL)
    print("Video Recorded: ", outputFileURL, /error?.localizedDescription)
  }
  
}
