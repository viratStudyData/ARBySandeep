//
//  MediaPicker.swift
//  BlockChain-Game
//
//  Created by MAC_MINI_6 on 11/12/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVFoundation
import Photos

enum MediaType: Int {
  case CameraForImageAndVideo //----- Images and Videos via Camera
  case CameraForImage //------------ Only Images via Camera
  case CameraForVideo //------------ Only Videos via Camera
  case LibraryForImageAndVideo //---- Images and Videos via Photos Library
  case LibraryForImage //----------- Only Images via Photos Library
  case LibraryForVideo //----------- Only Videos via Photos Library
  case ImageVideoCameraLibrary //---- Images and Videos both via Camera and Photo Library both
  case ImageCameraLibrary //--------- Only Images via Camera and Photo Library both
  case VideoCameraLibrary //--------- Only Videos via Camera and Photo Library both
  case DocumentOnly //-------------- Only Documents
  case AllOptions //---------------- Images, Videos & Documents via all Options available
  
  // Property to give mediaTypes to UIImagePickerController
  var mediaTypes: [String] {
    switch self {
    case .CameraForImageAndVideo, .LibraryForImageAndVideo, .ImageVideoCameraLibrary, .AllOptions:
      // Full Access Video and Images
      return [kUTTypeImage as String, kUTTypeMovie as String, kUTTypeVideo as String]
    case .CameraForImage, .LibraryForImage, .ImageCameraLibrary:
      // Only Images
      return [kUTTypeImage as String]
      // Only Videos
    case .CameraForVideo, .LibraryForVideo, .VideoCameraLibrary:
      return [kUTTypeMovie as String, kUTTypeVideo as String]
    case .DocumentOnly:
      // Only Documents
      // No MediaType required because it handled by UIDocumentPickerViewController
      return []
    }
  }
}


enum SKMPStrings: String {
  case Camera = "Camera"
  case Library = "Photos"
  case Cancel = "Cancel"
  case Settings = "Settings"
  case PhotosAlert = "Photos permission is denied for this app. Go to Settings to allow permission for Photos."
  case CameraAlert = "Camera permission is denied for this app. Go to Settings to allow permission for camera."
  case PermissionDenied = "Permission Denied"
  case MicrophoneAlert = "Microphone permission is denied for this app. Go to Settings to allow permission for microphone."
  
  var localized: String {
    return self.rawValue
  }
}

class Document {
  var url: URL?
  var data: Data?
  var fileName: String?
  
  init(_url: URL?, _data: Data?, _fileName: String?) {
    url = _url
    data = _data
    fileName = _fileName
  }
}

class SKMediaPicker: NSObject {
  
  var pickerType: MediaType = .CameraForImageAndVideo
  private var mediaPickerVC = UIImagePickerController()
  private var documentPicker = UIDocumentPickerViewController(documentTypes: [String(kUTTypeText),String(kUTTypeContent),String(kUTTypeItem),String(kUTTypeData)], in: .import)
  
  typealias DidPickImage = (_ image: UIImage) -> Void
  typealias DidPickeVideo = (_ url: URL, _ data: Data?, _ thumbnail: UIImage) -> Void
  typealias DidPickDocument = (_ document: [Document]?) -> Void
  
  private var didPickImage: DidPickImage?
  private var didPickVideo: DidPickeVideo?
  private var didPickDocument: DidPickDocument?
  
  
  init(type: MediaType, allowMultipleDocs: Bool = false) {
    super.init()
    pickerType = type
    mediaPickerVC.delegate = self
    mediaPickerVC.navigationBar.barStyle = .default
    mediaPickerVC.mediaTypes = type.mediaTypes
    documentPicker.delegate = self
    documentPicker.allowsMultipleSelection = allowMultipleDocs
  }
  
  func presentPicker(_ _didPickImage: DidPickImage? = nil, _ _didPickVideo: DidPickeVideo? = nil, _ _didPickDocs: DidPickDocument? = nil) {
    didPickImage = _didPickImage
    didPickVideo = _didPickVideo
    didPickDocument = _didPickDocs
    handleActionSheet()
  }
  
  private func handleActionSheet() {
    switch pickerType {
    case .CameraForImage, .CameraForImageAndVideo, .CameraForVideo:
      //No Action Sheet Required
      mediaPickerVC.sourceType = .camera
      handleCameraPermission()
    case .LibraryForVideo, .LibraryForImage, .LibraryForImageAndVideo:
      //No Action Sheet Required
      mediaPickerVC.sourceType = .photoLibrary
      handleLibraryPermission()
    case .DocumentOnly:
      handleDocPickerPermission()
    case .ImageCameraLibrary, .ImageVideoCameraLibrary, .VideoCameraLibrary:
      //Action Sheet to choose from Camera or Library
      let actionSheet = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
      actionSheet.addAction(UIAlertAction.init(title: SKMPStrings.Camera.localized, style: .default, handler: { (_) in
        self.mediaPickerVC.sourceType = .camera
        self.handleCameraPermission()
      }))
      actionSheet.addAction(UIAlertAction.init(title: SKMPStrings.Library.localized, style: .default, handler: { (_) in
        self.mediaPickerVC.sourceType = .photoLibrary
        self.handleLibraryPermission()
      }))
      actionSheet.addAction(UIAlertAction.init(title: SKMPStrings.Cancel.localized, style: .cancel, handler: { (_) in
        
      }))
      UIApplication.topVC()?.present(actionSheet, animated: true, completion: nil)
    case .AllOptions:
      break
    }
  }
  
  private func handleLibraryPermission() {
    switch PHPhotoLibrary.authorizationStatus() {
    case .authorized:
      UIApplication.topVC()?.present(mediaPickerVC, animated: true, completion: nil)
    case .notDetermined:
      PHPhotoLibrary.requestAuthorization { [unowned self] (status) in
        if status == .authorized {
           UIApplication.topVC()?.present(self.mediaPickerVC, animated: true, completion: nil)
        }
      }
    case .denied, .restricted:
      showPermissionAlert(SKMPStrings.PhotosAlert.localized)
    @unknown default:
        fatalError()
    }
  }
  
  private func handleCameraPermission() {
    switch AVCaptureDevice.authorizationStatus(for: .video) {
    case .notDetermined:
      AVCaptureDevice.requestAccess(for: .video) { [weak self] (isAllowed) in
        if isAllowed {
          guard let topVC = UIApplication.topVC() else {
            return
          }
          topVC.present(self?.mediaPickerVC ?? UIViewController(), animated: true, completion: nil)
        }
      }
    case .authorized:
      UIApplication.topVC()?.present(mediaPickerVC, animated: true, completion: nil)
    case .denied, .restricted:
      showPermissionAlert(SKMPStrings.CameraAlert.localized)
    @unknown default:
        fatalError()
    }
  }
  
  private func handleDocPickerPermission() {
    
  }
  
  //MARK:- Used in AR Camera
  public func permissionCheckForVideoRecording(success: (() -> Void)?) {
    var isCalledSuccess = false
    switch (AVCaptureDevice.authorizationStatus(for: .video)) {
    case .notDetermined:
      AVCaptureDevice.requestAccess(for: .video) { (isAllowed) in
        if isAllowed && AVCaptureDevice.authorizationStatus(for: .audio) == .authorized {
          isCalledSuccess = true
          success?()
        }
      }
    case .authorized:
      if AVCaptureDevice.authorizationStatus(for: .audio) == .authorized {
        isCalledSuccess = true
        success?()
      }
    case .denied, .restricted:
      showPermissionAlert(SKMPStrings.CameraAlert.localized)
    @unknown default:
        fatalError()
    }
    
    switch AVCaptureDevice.authorizationStatus(for: .audio) {
    case .notDetermined:
      AVCaptureDevice.requestAccess(for: .audio) { (isAllowed) in
        if isAllowed && AVCaptureDevice.authorizationStatus(for: .video) == .authorized && !isCalledSuccess {
          success?()
        }
      }
    case .authorized:
      if AVCaptureDevice.authorizationStatus(for: .video) == .authorized && !isCalledSuccess {
        success?()
      }
    case .denied, .restricted:
      showPermissionAlert(SKMPStrings.MicrophoneAlert.localized)
    @unknown default:
        fatalError()
    }
  }
  
  private func openSettingsApp() {
    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
  }
  
  private func showPermissionAlert(_ message: String) {
    let alert = UIAlertController.init(title: SKMPStrings.PermissionDenied.localized, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction.init(title: SKMPStrings.Cancel.localized, style: .destructive, handler: { (_) in
      
    }))
    alert.addAction(UIAlertAction.init(title: SKMPStrings.Settings.localized, style: .default, handler: { (_) in
      self.openSettingsApp()
    }))
    UIApplication.topVC()?.present(alert, animated: true, completion: nil)
  }
  
  func generateThumbnailfrom(url: URL) -> UIImage {
    let asset = AVAsset(url: url)
    let generator = AVAssetImageGenerator(asset: asset)
    generator.appliesPreferredTrackTransform = true
    var time = asset.duration
    time.value = 0
    let imageRef = try? generator.copyCGImage(at: time, actualTime: nil)
    let thumbnail = UIImage(cgImage: imageRef!)
    return thumbnail
  }
  
  private func fixOrientation(of image: UIImage) -> UIImage {
    if image.imageOrientation == UIImage.Orientation.up {
      return image
    }
    UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
    image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
    if let normalizedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext() {
      UIGraphicsEndImageContext()
      return normalizedImage
    } else {
      return image
    }
  }
}

//MARK:- UIImagePickerController Delegate
extension SKMediaPicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    picker.dismiss(animated: true, completion: nil)
    let pickedMediaType = info[UIImagePickerController.InfoKey.mediaType] as! NSString
    
//    let assetPath = info[UIImagePickerController.InfoKey.imageURL] as! NSURL
//    if (assetPath.absoluteString?.hasSuffix("JPG"))! || (assetPath.absoluteString?.hasSuffix("jpeg"))! {
//      print("JPG")
//    }
//    else if (assetPath.absoluteString?.hasSuffix("PNG"))! || (assetPath.absoluteString?.hasSuffix("png"))!{
//      print("PNG")
//    }
//    else if (assetPath.absoluteString?.hasSuffix("GIF"))! || (assetPath.absoluteString?.hasSuffix("gif"))!{
//      print("GIF")
//    }
//    else {
//      print("Unknown")
//    }
    
    if pickedMediaType.isEqual(to: kUTTypeImage as String) {
      let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
      didPickImage?(fixOrientation(of: selectedImage))
    } else if pickedMediaType.isEqual(to: kUTTypeMovie as String) || pickedMediaType.isEqual(to: kUTTypeVideo as String) {
      let selectedVideoURL = info[UIImagePickerController.InfoKey.mediaURL] as! URL
      let videoData = try? Data(contentsOf: selectedVideoURL)
      let thumbnail = generateThumbnailfrom(url: selectedVideoURL)
      didPickVideo?(selectedVideoURL, videoData, thumbnail)
    }
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true, completion: nil)
  }
}

//MARK:- UIDocumentPicker Delegate
extension SKMediaPicker: UIDocumentPickerDelegate {
  func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
    var docs = [Document]()
    urls.forEach { (fileURL) in
      let fileName = fileURL.lastPathComponent
      let data = try? Data(contentsOf: fileURL)
      docs.append(Document.init(_url: fileURL, _data: data, _fileName: fileName))
    }
    didPickDocument?(docs)
  }

  func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
    controller.dismiss(animated: true, completion: nil)
  }
}


//MARK:- Plist Camera Parmission
//<key>NSCameraUsageDescription</key>
//<string>camera description.</string>
//MARK:- Plist PhotoLibrary Permission
//<key>NSPhotoLibraryUsageDescription</key>
//<string> photos description.</string>
