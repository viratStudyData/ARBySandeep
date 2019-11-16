//
//  DownloadPreference.swift
//  AE
//
//  Created by MAC_MINI_6 on 30/05/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit

//TWRDownloadManager

enum DownloadContentType: Int {
  case Objects
  case Packages
}

enum FileName: String {
  case ORIGINAL_IMAGE = "original_"
  case OBJECT_FILE = "object_"
  case THUMB_IMAGE = "thumb_"
  case VIDEO = "video_"
  case PACKAGE_ORIGINAL = "package_"
  case FILTER = "filter_"
  case LENSE = "lense_"
  case LOGO = "logo_"
  case BACKGROUND = "background_"
  case TRIGGERRING_IMAGE = "triggerImage_"
  case PROFILE = "profile_"
//  case TEXTURE = "textureImage_"
}

final class DownloadPreference {
  let PACKAGE_KEY = "AUGMENTED_EXPERIENCE_PACKAGE_KEY"
  let OBJECTS_KEY = "AUGMENTED_EXPERIENCE_OBJECTS_KEY"
  
  static let shared = DownloadPreference()
  
  private init() {
    
  }
  
  var objects: [Object]? {
    get {
      return fetchObjects()
    }
    set {
      if let value = newValue {
        saveObjects(value)
      } else {
        UserDefaults.standard.removeObject(forKey: PACKAGE_KEY)
      }
    }
  }
  
  private func fetchObjects() -> [Object]? {
    guard let data = UserDefaults.standard.data(forKey: OBJECTS_KEY) else {
      return nil
    }
    return JSONHelper<[Object]>().getCodableModel(data: data)
  }
  
  private func saveObjects(_ value: [Object]) {
    guard let data = JSONHelper<[Object]>().getData(model: value) else {
      UserDefaults.standard.removeObject(forKey: OBJECTS_KEY)
      return
    }
    UserDefaults.standard.set(data, forKey: OBJECTS_KEY)
  }
}

//MARK:- Objects downloads handling
extension DownloadPreference {
  func getImageFrom(path: String, localImage: ((_ image: UIImage?) -> Void)? ) {
    let url = URL(fileURLWithPath: path)
    do {
      let imageData = try Data(contentsOf: url)
      localImage?(UIImage(data: imageData))
    } catch {
      print("Error loading image : \(error)")
    }
  }
  
  func delete(obj: Object?) {
    let fileManager : FileManager = FileManager.default
    do  {
      try fileManager.removeItem(at: URL(fileURLWithPath: "\(MZUtility.baseFilePath)/\(/obj?.objectUrl?.fileName)"))
      try fileManager.removeItem(at: URL(fileURLWithPath: "\(MZUtility.baseFilePath)/\(/obj?.objectUrl?.thumbnailName)"))
      try fileManager.removeItem(at: URL(fileURLWithPath: "\(MZUtility.baseFilePath)/\(/obj?.mediaUrlSigned?.fileName)"))
      try obj?.imageUrl?.forEach({ (image) in
        try fileManager.removeItem(at: URL(fileURLWithPath: "\(MZUtility.baseFilePath)/\(/image.fileName)"))
      })
    } catch {
      print("------------File not found to delete-------------")
    }
    var tempData = objects
    guard let index: Int = tempData?.firstIndex(of: obj!) else { return }
    tempData?.remove(at: index)
    objects = tempData
  }
  
  func getCompletedDownloads() -> [Object]? {
    let completedObjects = objects?.filter({$0.objectUrl?.downloadStatus == .DOWNLOADED || $0.mediaUrlSigned?.downloadStatus == .DOWNLOADED})
    return completedObjects
  }
  
  func getTrigerringObjects() -> [Object]? {
    return objects?.filter({$0.objectUrl?.downloadStatus == .DOWNLOADED || $0.mediaUrlSigned?.downloadStatus == .DOWNLOADED})
  }
  
  func getObj(for id: String?) -> Object? {
    
    return objects?.first(where: {/$0._id == /id })
  }
  
  func getObjects(for package: Package?) -> [Object] {
    let tempData = objects
    let packageObjects = tempData?.filter({ /$0.packageId?._id == /package?._id && $0.objectUrl?.downloadStatus == .DOWNLOADED })
    return packageObjects ?? []
  }
  
  func syncObjectsForURLs(backendObjects: [Object]?) {
    let tempObjects = objects ?? []
    for obj in tempObjects {
      if let backObj = backendObjects?.first(where: {$0 == obj }) {
        let components = backObj.mediaUrlSigned?.thumbnail?.components(separatedBy: "/")
        let fileName = (/components?.first(where: { $0.contains("thumb_") })).components(separatedBy: "?").first
        obj.mediaUrlSigned?.fileName = fileName
        obj.objectUrl?.gltf = backObj.objectUrl?.gltf
        obj.mediaUrlSigned?.original = backObj.mediaUrlSigned?.original
        obj.mediaUrlSigned?.thumbnail = backObj.mediaUrlSigned?.thumbnail
      }
    }
    objects = tempObjects
  }
  
  func getSyncedObjectsForStatus(backendObjects: [Object]?) -> [Object] {
    let tempObjects = backendObjects ?? []
    let downloadedObjects = objects?.filter({ $0.objectUrl?.downloadStatus == .DOWNLOADED  || $0.mediaUrlSigned?.downloadStatus == .DOWNLOADED}) ?? []
    for obj in tempObjects {
      if downloadedObjects.contains(obj) {
        obj.objectUrl?.downloadStatus = .DOWNLOADED
        obj.mediaUrlSigned?.downloadStatus = .DOWNLOADED
      }
    }
    return tempObjects
  }

  func addObjToDownloads(obj: Object?, block: ((_ isAlreadyExist: Bool) -> Void)? ) {
    guard let newObject = obj else {
      return
    }
    let tempData = objects ?? []
    if tempData.contains(newObject) {
      let tempData = objects
      tempData?.first(where: {$0 == newObject})?.objectUrl?.gltf = newObject.objectUrl?.gltf
      tempData?.first(where: {$0 == newObject})?.mediaUrlSigned?.original = newObject.mediaUrlSigned?.original
      tempData?.first(where: {$0 == newObject})?.mediaUrlSigned?.thumbnail = newObject.mediaUrlSigned?.thumbnail
      objects = tempData
      
      
      block?(true)
      if let itemToDwnld = objects?.first(where: {/$0._id == /newObject._id  && $0.objectUrl?.downloadStatus != .DOWNLOADED }) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.downloadManager.downloadingArray.contains(where: {/$0.fileName == /itemToDwnld.objectUrl?.fileName}) {
          //Downloading exist in MZDownload array
          switch /appDelegate.downloadManager.downloadingArray.first(where: {$0.fileName == /itemToDwnld.objectUrl?.fileName})?.status {
          case TaskStatus.failed.description():
            guard let index: Int = appDelegate.downloadManager.downloadingArray.firstIndex(where: {/$0.fileName == /itemToDwnld.objectUrl?.fileName}) else {
              return
            }
            appDelegate.downloadManager.retryDownloadTaskAtIndex(index)
          case TaskStatus.paused.description():
            guard let index: Int = appDelegate.downloadManager.downloadingArray.firstIndex(where: {/$0.fileName == /itemToDwnld.objectUrl?.fileName}) else {
              return
            }
            appDelegate.downloadManager.resumeDownloadTaskAtIndex(index)
          default: break
          }
        } else {

          if itemToDwnld.objectUrl ==  nil {
            return
          }
          //Downloading in list but not in MZDownload array
          appDelegate.downloadManager.addDownloadTask(/itemToDwnld.objectUrl?.fileName, request: URLRequest(url: URL.init(string: /itemToDwnld.objectUrl?.gltf)!), destinationPath: MZUtility.baseFilePath)
          appDelegate.downloadManager.addDownloadTask(/itemToDwnld.objectUrl?.thumbnailName, request: URLRequest(url: URL.init(string: /itemToDwnld.objectUrl?.thumbnail)!), destinationPath: MZUtility.baseFilePath)
          itemToDwnld.imageUrl?.forEach({ (image) in
            appDelegate.downloadManager.addDownloadTask(/image.fileName, request: URLRequest(url: URL.init(string: /image.original)!), destinationPath: MZUtility.baseFilePath)
          })
        }
      }
      print("--------------Aleardy exist in Download Preferences---------")
      return
    }
    block?(false)
    objects = tempData + [newObject]
  }
  
  //MARK:- To update status of downloads
  public func updateStatus(status: DownloadStatus, fileName: String?) {
    if /fileName?.contains(FileName.OBJECT_FILE.rawValue) { //Object
      updateStatusOfObject(status: status, fileName: fileName)
    } else if /fileName?.contains(FileName.TRIGGERRING_IMAGE.rawValue) { // Images triggered
      updateStatusOfObjectImage(status: status, fileName: fileName)
    } else if /fileName?.contains(FileName.PACKAGE_ORIGINAL.rawValue) { // Package thumbnail
//      updateStatusOfPackageThumbnail(status: status, fileName: fileName)
    } else if /fileName?.contains(FileName.THUMB_IMAGE.rawValue) { // Thumbnail of object
      updateThumbnailOfObject(status: status, fileName: fileName)
    }
  }
  
  //MARK:- Object status update
  private func updateStatusOfObject(status: DownloadStatus, fileName: String?) {
    let tempData = objects
    tempData?.first(where: {/$0.objectUrl?.fileName == /fileName})?.objectUrl?.downloadStatus = status
    objects = tempData
  }
  
  //MARK:- Object thumbnail update //DOUBT
  private func updateThumbnailOfObject(status: DownloadStatus, fileName: String?) {
    let tempData = objects
    tempData?.first(where: {/$0.mediaUrlSigned?.fileName == /fileName})?.mediaUrlSigned?.downloadStatus = status
    tempData?.first(where: {/$0.objectUrl?.thumbnailName == /fileName})?.objectUrl?.downloadStatus = status
    objects = tempData
  }
  
  //MARK:- Triggered images update
  private func updateStatusOfObjectImage(status: DownloadStatus, fileName: String?) {
    var tempData = objects
    
    guard let obj = tempData?.first(where: { (obj) -> Bool in
      return /obj.imageUrl?.contains(where: { /$0.fileName == /fileName})
    }) else {
      return
    }
    obj.imageUrl?.first(where: {/$0.fileName == /fileName})?.downloadStatus = status
    guard let index: Int = tempData?.firstIndex(of: obj) else {
      return
    }
    tempData?[index] = obj
    objects = tempData
  }
  
//  private func updateStatusOfPackageThumbnail(status: DownloadStatus, fileName: String?) {
//    let tempData = objects
//
//    tempData?.forEach({ (obj) in
//      if /obj.packageId?.imageUrl?.fileName == /fileName {
//        obj.packageId?.imageUrl?.downloadStatus = status
//      }
//    })
//    objects = tempData
//  }
  
}
