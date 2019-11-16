//
//  BaseVC.swift
//  AE
//
//  Created by MAC_MINI_6 on 25/03/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import KVSpinnerView

class BaseVC: UIViewController {

  lazy var accessory: ContinueAccessory = {
    let rect = CGRect(x: 0,y: 0,width: UIScreen.main.bounds.width, height: 72)
    let continueAccessory = ContinueAccessory(frame: rect)
    return continueAccessory
  }()
  
  
  lazy var saveAccessory: SaveAccessory = {
    let rect = CGRect(x: 0,y: 0,width: UIScreen.main.bounds.width, height: ScreenSize.SCREEN_WIDTH * (56 / 375))
    let _saveAccessory = SaveAccessory(frame: rect)
    return _saveAccessory
  }()
  
  lazy var phoneServices: PhoneServices = {
    let phoneServicesInstance = PhoneServices()
    return phoneServicesInstance
  }()
  
  var mediaPicker = SKMediaPicker(type: .CameraForImage)
  var tfResponder: TFResponder?
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(true)
    if self.isKind(of: SignUpVC.self) || self.isKind(of: SetPasswordVC.self) || self.isKind(of: ChangePSWVC.self) || self.isKind(of: EditProfileVC.self) {
      IQKeyboardManager.shared.enableAutoToolbar = false
    } else {
      IQKeyboardManager.shared.enableAutoToolbar = true
    }
    navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    navigationController?.interactivePopGestureRecognizer?.delegate = self
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    view.endEditing(true)
  }

  func tapObjectAction(with obj: Object?) {
    
    switch obj?.mediaType ?? .OBJECT {
    case .OBJECT:
      actionSheet(for: [VCLiteral.OBJECT_VIEW_OPTION_1.localized,
                        VCLiteral.OBJECT_VIEW_OPTION_2.localized], title: VCLiteral.OBJECT_VIEW_TITLE.localized, message: nil) { [weak self] (tappedTitle) in
                          switch tappedTitle {
                          case VCLiteral.OBJECT_VIEW_OPTION_1.localized: //Camera
                            self?.openARCameraVC(with: obj)
                          case VCLiteral.OBJECT_VIEW_OPTION_2.localized: // 3D Scene
                            let destVC = StoryboardScene.Other.ObjPreviewVC.instantiate()
                            destVC.obj = obj
                            self?.pushVC(destVC)
                          default: break
                          }
      }
    default:
      mediaPreview(with: obj)
    }
  }
  
  func mediaPreview(with obj: Object?) {
    switch obj?.mediaType ?? .OBJECT {
    case .IMAGE:
      guard let image = obj?.mediaUrlSigned else { return }
      let destVC = StoryboardScene.Other.MediaPreviewVC.instantiate()
      destVC.item = ([image], 0)
      UIApplication.topVC()?.pushVC(destVC)
    case .VIDEO:
       UIApplication.topVC()?.playVideo(URL(string: /obj?.mediaUrlSigned?.original))
    case .VIDEO360:
      KVSpinnerView.show()
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { [weak self] in
        let destVC = StoryboardScene.Other.Video360VC.instantiate()
        destVC.urlString = /obj?.mediaUrlSigned?.original
        UIApplication.topVC()?.presentVC(destVC)
      })
    case .IMAGE360:
      let destVC = StoryboardScene.Other.Image360VC.instantiate()
      destVC.url = URL(string: /obj?.mediaUrlSigned?.original)
      UIApplication.topVC()?.presentVC(destVC)
    default:
      break
    }
  }
  
  func openARCameraVC(with obj: Object?) {
    SKMediaPicker.init(type: .AllOptions).permissionCheckForVideoRecording { [weak self] in
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
        let destVC = StoryboardScene.Other.CameraVC.instantiate()
        destVC.objToPreview = obj
        destVC.isScanning = false
        self?.pushVC(destVC)
      })
    }
  }
}

extension BaseVC: UIGestureRecognizerDelegate {
  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    if isKind(of: CameraVC.self) || isKind(of: ShareVideoImgVC.self) || isKind(of: HomeVC.self) || isKind(of: TabVC.self) {
      return false
    }
    return true
  }
  
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return false
  }
}
