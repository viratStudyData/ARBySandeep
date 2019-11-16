//
//  CameraVC.swift
//  AE
//
//  Created by MAC_MINI_6 on 10/06/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit
import ARKit
import GLTFSceneKit

class CameraVC: BaseVC {

  @IBOutlet weak var arSCNView: ARSCNView!
  @IBOutlet weak var btnCapture: UIButton!
  @IBOutlet weak var btnWeb: UIButton!
  @IBOutlet weak var lblTimer: UILabel!
  @IBOutlet weak var btnRotation: UIButton!
  
  var objToPreview: Object?
  private var recorder: RecordAR?
  var isScanning = false
  private var referenceImages: [ImageURL]?
  private let configuration = ARWorldTrackingConfiguration()
  private var current3DObjNode: SCNNode?
  private let recordingQueue = DispatchQueue(label: "recordingThread", attributes: .concurrent)
  
  //Store The Rotation Of The CurrentNode
  private var currentAngleY: Float = 0.0
  private var currentAngleX: Float = 0.0
  
  private var isRotatingOn = true
  private var timer: Timer?
  private var timeMin = 0
  private var timeSec = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    btnCapture.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(singleTap(gesture:))))
    btnCapture.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longPress(gesture:))))
    recorder = RecordAR(ARSceneKit: arSCNView)
//    recorder?.delegate = self
//    recorder?.renderAR = self
    recorder?.onlyRenderWhileRecording = true
    recorder?.contentMode = .aspectFill
    recorder?.enableAdjustEnvironmentLighting = true
    recorder?.inputViewOrientations = [.landscapeLeft, .landscapeRight, .portrait]
    recorder?.deleteCacheWhenExported = true
    if let _ = objToPreview {
      loadObjInCamera()
    } else {
      btnWeb.isHidden = true
      btnRotation.isHidden = true
    }
    arSCNView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panGesture(_:)) ))
    arSCNView.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(pinchGesture(_:)) ))
    let tap = UITapGestureRecognizer.init(target: self, action: #selector(doubleTap(sender:)))
    tap.numberOfTapsRequired = 2
    arSCNView.addGestureRecognizer(tap)
  }
  
  override func didReceiveMemoryWarning() {
    print("********************************* Memory Warning ****************************  *****")
  }
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    setConfiguration()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(true)
    // Pause the view's session
    arSCNView.session.pause()
    if recorder?.status == .recording {
      recorder?.stopAndExport()
    }
    recorder?.onlyRenderWhileRecording = true
    recorder?.prepare(ARWorldTrackingConfiguration())
    
    // Switch off the orientation lock for UIViewControllers with AR Scenes
    recorder?.rest()
  }
  
  @IBAction func btnRotaionAction(_ sender: UIButton) {
//    let frontCamVC = StoryboardScene.Other.FrontCamVC.instantiate()
//    replaceLastVCInStack(with: frontCamVC)
    isRotatingOn.toggle()
    sender.setImage(isRotatingOn ? #imageLiteral(resourceName: "active_360") : #imageLiteral(resourceName: "inactive_360"), for: .normal)
  }
  
  @IBAction func btnWebAction(_ sender: Any) {
    presentSafariVC(urlString: /objToPreview?.objectLink)
  }
  
  @IBAction func btnCloseAction(_ sender: UIButton) {
//    arSCNView.session.pause()
//    recorder?.gpuLoop.remove(from: .main, forMode: .common )
    popVC()
  }
  
    @objc func doubleTap(sender: UITapGestureRecognizer) {
        if isScanning {
            let vc = StoryboardScene.Other.FrontCamVC.instantiate()
            navigationController?.replaceTopViewController(with: vc, animated: false)
        }
    }
    
  @objc func panGesture(_ gesture: UIPanGestureRecognizer) {
    if isRotatingOn {
      guard let direction = gesture.direction else { return }
      switch direction {
      case .Down, .Up:
        let translation = gesture.translation(in: gesture.view)
        var newAngleX = (Float)(translation.y)*(Float)(Double.pi)/180.0
        newAngleX += currentAngleX
        current3DObjNode?.eulerAngles.x = newAngleX
        if gesture.state == .ended {
          currentAngleX = newAngleX
        }
      case .Right, .Left:
        let translation = gesture.translation(in: gesture.view)
        var newAngleY = (Float)(translation.x)*(Float)(Double.pi)/180.0
        newAngleY += currentAngleY
        current3DObjNode?.eulerAngles.y = newAngleY
        if gesture.state == .ended {
          currentAngleY = newAngleY
        }
      }
    } else {
      gesture.minimumNumberOfTouches = 1
      
      let results = arSCNView.hitTest(gesture.location(in: arSCNView), types: .featurePoint)
      
      print("ARHITResults: ", results)
      guard let result: ARHitTestResult = results.first else { return }
//      let hits = arSCNView.hitTest(gesture.location(in: gesture.view), options: nil)
      
      let matrixColumn3 = result.worldTransform.columns.3
      let position = SCNVector3(matrixColumn3.x, matrixColumn3.y, matrixColumn3.z)
      current3DObjNode?.position = position

//      if let tappedNode = hits.first?.node {
//        let matrixColumn3 = result.worldTransform.columns.3
//        let position = SCNVector3(matrixColumn3.x, matrixColumn3.y, matrixColumn3.z)
//        tappedNode.position = position
//        current3DObjNode?.position = position
//      }
    }
  }
  
  @objc func pinchGesture(_ gesture: UIPinchGestureRecognizer) {

    guard let nodeToScale = current3DObjNode else { return }
    if gesture.state == .changed {
      let pinchScaleX: CGFloat = gesture.scale * CGFloat((nodeToScale.scale.x))
      let pinchScaleY: CGFloat = gesture.scale * CGFloat((nodeToScale.scale.y))
      let pinchScaleZ: CGFloat = gesture.scale * CGFloat((nodeToScale.scale.z))
      nodeToScale.scale = SCNVector3(Float(pinchScaleX), Float(pinchScaleY), Float(pinchScaleZ))
      gesture.scale = 1
    }
    if gesture.state == .ended { }
  }
}

//MARK:- VCFuncss
extension CameraVC {
  func setConfiguration() {
    if isScanning {
      setARReferenceImages()
    } else {
      // Create a session configuration
      configuration.worldAlignment = .gravity
      configuration.planeDetection = .horizontal
      let options: ARSession.RunOptions = [.resetTracking, .removeExistingAnchors]
      // Run the view's session
      arSCNView.session.run(configuration, options: options)
      arSCNView.antialiasingMode = .multisampling4X
      arSCNView.automaticallyUpdatesLighting = true
      arSCNView.autoenablesDefaultLighting = true
      arSCNView.showsStatistics = false
      arSCNView.delegate = self
      
      recorder?.prepare(configuration)
    }
  }
  
  //Get AR Refrence Images to trigger
  func setARReferenceImages() {
    let downloadObjects = DownloadPreference.shared.getTrigerringObjects() ?? []
    let allImages = Array(downloadObjects.compactMap({$0.imageUrl}).joined())
    referenceImages = allImages
    
    var customReferenceSet = Set<ARReferenceImage>()
    allImages.forEach({ (img) in
      DownloadPreference.shared.getImageFrom(path: "\(MZUtility.baseFilePath)/\(/img.fileName)", localImage: { (uiImage) in
        guard let cgImage = uiImage?.cgImage else {
          return
        }
        let referenceImage = ARReferenceImage.init(cgImage, orientation: CGImagePropertyOrientation.up, physicalWidth: CGFloat(cgImage.width))
        referenceImage.name = /img.fileName
        customReferenceSet.insert(referenceImage)
      })
    })
    
    configuration.worldAlignment = .gravity
    configuration.planeDetection = .horizontal
    configuration.detectionImages = customReferenceSet
    let options: ARSession.RunOptions = [.resetTracking, .removeExistingAnchors]
    recorder?.prepare(configuration)
    arSCNView.antialiasingMode = .multisampling4X
    arSCNView.automaticallyUpdatesLighting = true
    arSCNView.autoenablesDefaultLighting = true
    arSCNView.showsStatistics = false
    arSCNView.delegate = self
    arSCNView.session.run(configuration, options: options)
  }
  
  //Image Capture actions
  @objc func singleTap(gesture: UITapGestureRecognizer) {
    guard let image = recorder?.photo() else {
      return
    }
    let destVC = StoryboardScene.Other.ShareVideoImgVC.instantiate()
    destVC.shareItem = ShareItemType.image(uiImage: image)
    pushVC(destVC, animated: false)
  }
  
  //Video Recording actions
  @objc func longPress(gesture: UILongPressGestureRecognizer) {
    switch gesture.state {
    case .began: // Start Video Recording
      btnCapture.setImage(#imageLiteral(resourceName: "ic_record"), for: .normal)
      recordingQueue.async { [weak self] in
        print("================Video Recording Started=================")
        self?.recorder?.record()
      }
      startTimer()
    case .ended: // End Video Recording
     
      if /timeSec < 4 {
        recorder?.stop()
        Toast.shared.showAlert(type: .validationFailure, message: "Minimum video recording should exceed 3 seconds.")
        resetTimerToZero()
        return
      }
      btnCapture.setImage(#imageLiteral(resourceName: "ic_capture"), for: .normal)
      if recorder?.status == .recording {
        recorder?.stop({ [weak self] (localURL) in
          print("================Video Recording Completed=================")
          print(localURL)
          
          let destVC = StoryboardScene.Other.ShareVideoImgVC.instantiate()
          destVC.shareItem = ShareItemType.video(localURL: localURL)
          DispatchQueue.main.async {
            self?.pushVC(destVC, animated: false)
          }

        })
      }
     resetTimerToZero()
    default:
      break
    }
  }
  
  func loadObjInCamera() {
    btnWeb.isHidden = /objToPreview?.objectLink == ""
    
    if objToPreview?.objectUrl == nil {
      mediaPreview(with: objToPreview)
      btnRotation.isHidden = true
      return
    } else {
      btnRotation.isHidden = false
    }
    
    
    do {
//      let urlString = Bundle.main.path(forResource: "object_1562750544004.gltf", ofType: "")
      let urlString = "\(MZUtility.baseFilePath)/\(/objToPreview?.objectUrl?.fileName)"
      let sceneSource = try GLTFSceneSource.init(url: URL.init(fileURLWithPath: /urlString))
      let objectNode = try sceneSource.scene().rootNode
      objectNode.scale = SCNVector3(0.15, 0.15, 0.15)
      objectNode.position = SCNVector3(0, -0.2, -0.8)
      arSCNView.scene.rootNode.addChildNode(objectNode)
      current3DObjNode = objectNode
      
    } catch {
      print("\(error.localizedDescription)")
      return
    }
    
//    let mdlAsset = MDLAsset(url: URL(fileURLWithPath: "\(MZUtility.baseFilePath)/\(/objToPreview?.objectUrl?.fileName)"))
//
//    let scatteringFunction = MDLScatteringFunction.init()
//    let material = MDLMaterial.init(name: "baseMaterial", scatteringFunction: scatteringFunction)
//
//    material.setTextureProperties(textures: [MDLMaterialSemantic.baseColor : /objToPreview?.objectUrl?.textureName])
//
//    for mesh in ((mdlAsset.object(at: 0) as? MDLMesh)?.submeshes as? [MDLSubmesh]) ?? [] {
//      print("Mesh Name: \(mesh.name)")
//      mesh.material = material
//    }
//    mdlAsset.loadTextures()
//    let objectNode = SCNNode(mdlObject: mdlAsset.object(at: 0))
//    objectNode.scale = SCNVector3(0.15, 0.15, 0.15)
//    objectNode.position = SCNVector3(0, -0.2, -0.8)
//    arSCNView.scene.rootNode.addChildNode(objectNode)
//    current3DObjNode = objectNode
  }
  
  // MARK:- Timer Functions
  private func startTimer(){
    // if you want the timer to reset to 0 every time the user presses record you can uncomment out either of these 2 lines
    
    // timeSec = 0
    // timeMin = 0
    
    // If you don't use the 2 lines above then the timer will continue from whatever time it was stopped at
    let timeNow = String(format: "%02d:%02d", timeMin, timeSec)
    lblTimer.text = timeNow
    
    stopTimer() // stop it at it's current time before starting it again
    lblTimer.isHidden = false
    timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
      self?.timerTick()
    }
  }
  
  private func timerTick(){
    timeSec += 1
    
    if timeSec == 60{
      timeSec = 0
      timeMin += 1
    }
    
    let timeNow = String(format: "%02d:%02d", timeMin, timeSec)
    print(timeNow)
    lblTimer.isHidden = false
    lblTimer.text = timeNow
  }
  
  // resets both vars back to 0 and when the timer starts again it will start at 0
  private func resetTimerToZero(){
    timeSec = 0
    timeMin = 0
    stopTimer()
  }
  
  // if you need to reset the timer to 0 and yourLabel.txt back to 00:00
  private func resetTimerAndLabel(){
  
    resetTimerToZero()
    lblTimer.text = String(format: "%02d:%02d", timeMin, timeSec)
  }
  
  // stops the timer at it's current time
  private func stopTimer(){
    lblTimer.isHidden = true
    timer?.invalidate()
  }
  
}

//MARK:- ARSCNViewDelegate
extension CameraVC: ARSCNViewDelegate {
  
  
  func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    
    if !isScanning {
//      guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
//      
//      // 2
//      let width = CGFloat(planeAnchor.extent.x)
//      let height = CGFloat(planeAnchor.extent.z)
////      let plane = SCNPlane(width: width, height: height)
////      current3DObjNode?.scale = SCNVector3(0.15, 0.15, 0.15)
//      current3DObjNode?.position.z = -planeAnchor.center.z
////      current3DObjNode?.position = SCNVector3(CGFloat(planeAnchor.center.x), CGFloat(planeAnchor.center.y), -CGFloat(planeAnchor.center.z))
////      current3DObjNode?.eulerAngles.x = -.pi / 2
////
      return
    }
    
    guard let imageAnchor = anchor as? ARImageAnchor else { return }

    let referenceImage = imageAnchor.referenceImage
    let imageName = referenceImage.name ?? "no name"
    
    if objToPreview != nil {
      return
    }
    
    DispatchQueue.main.async { [weak self] in
      if let objectId = self?.referenceImages?.first(where: {$0.fileName == imageName})?.objectId {
//        self?.arSCNView.scene.rootNode
        guard let object = DownloadPreference.shared.getObj(for: objectId) else {
          return
        }
        self?.objToPreview = object
        self?.loadObjInCamera()
      }
    }
  }
}

