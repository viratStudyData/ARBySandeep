//
//  UIViewControllerExtensions.swift
//  AE
//
//  Created by MAC_MINI_6 on 19/03/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit
import AVKit
import MapKit
import SafariServices

extension UINavigationController {
    
    func popToViewController(ofClass: AnyClass, animated: Bool = true) {
        if let vc = viewControllers.filter({$0.isKind(of: ofClass)}).last {
            popToViewController(vc, animated: animated)
        }
    }
    
        func replaceTopViewController(with viewController: UIViewController, animated: Bool) {
            var vcs = viewControllers
            vcs[vcs.count - 1] = viewController
            setViewControllers(vcs, animated: animated)
        }
}

extension UIViewController {
  
  func presentSafariVC(urlString: String) {
    guard let url = URL(string: urlString) else {
      return
    }
    let vc = SFSafariViewController(url: url)
    vc.preferredControlTintColor = Color.buttonBlue.value
    presentVC(vc)
  }
  
  func pushVC(_ vc: UIViewController, animated: Bool = true) {
    navigationController?.pushViewController(vc, animated: animated)
  }
  
  func popVC(animated: Bool = true) {
    navigationController?.popViewController(animated: animated)
  }
  
  func presentVC(_ vc: UIViewController) {
    navigationController?.present(vc, animated: true, completion: nil)
  }
  
  func replaceLastVCInStack(with viewcontroller: UIViewController) {
    var vcArray = navigationController?.viewControllers
    viewcontroller.transition(from: (vcArray?.last)!, to: viewcontroller, duration: 0.5, options: UIView.AnimationOptions.autoreverse, animations: {
      
    }) { (completed) in
      vcArray!.removeLast()
      vcArray!.append(viewcontroller)
      self.navigationController?.setViewControllers(vcArray!, animated: true)
    }
  }
  
  func dismissVC() {
    dismiss(animated: true, completion: nil)
  }
  
    
  func topMostVC() -> UIViewController {
    let vc = UIApplication.topVC()
    guard let topVC = vc else {
      return UIViewController()
    }
    return topVC
  }
  
  func playVideo(_ url: URL?) {
    guard let localOrServerURL = url else {
      return
    }
    let player = AVPlayer(url: localOrServerURL)
    let playerViewController = AVPlayerViewController()
    playerViewController.player = player
    self.present(playerViewController, animated: true) {
      playerViewController.player!.play()
    }
  }
  
  func popTo<T: UIViewController>(toControllerType: T.Type) {
    if var viewControllers: [UIViewController] = self.navigationController?.viewControllers {
      viewControllers = viewControllers.reversed()
      for currentViewController in viewControllers {
        if currentViewController .isKind(of: toControllerType) {
          self.navigationController?.popToViewController(currentViewController, animated: true)
          break
        }
      }
    }
  }
  
    func popVCs(viewsToPop: Int, animated: Bool = true) {
        if /navigationController?.viewControllers.count > viewsToPop {
            guard let vc = navigationController?.viewControllers[/navigationController?.viewControllers.count - viewsToPop - 1] else { return }
            navigationController?.popToViewController(vc, animated: animated)
        }
    }
    
  func actionSheet(for actions: [String], title: String?, message: String?, tapped: ((_ actionString: String?) -> Void)?) {
    let actionSheetController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
    
    actions.forEach {
      
      let action = UIAlertAction(title: $0, style: .default, handler: { (action) in
        tapped?(action.title)
      })
      action.setValue(Color.textBlack90.value, forKey: "titleTextColor")
      actionSheetController.addAction(action)
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
      
    })
    cancelAction.setValue(Color.buttonBlue.value, forKey: "titleTextColor")
    actionSheetController.addAction(cancelAction)
    present(actionSheetController, animated: true, completion: nil)
  }
  
  func alertWithDesc(desc: String?) {
    let messageString = NSMutableAttributedString.init(string: /desc, attributes: [NSAttributedString.Key.font : Fonts.SFProTextMedium.ofSize(14),
                                                                                      NSAttributedString.Key.foregroundColor: Color.textBlack90.value])
    
    let alert = UIAlertController(title: "", message: desc, preferredStyle: .alert)
    alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: { (_) in
    }))
    alert.setValue(messageString, forKey: "attributedMessage")
    present(alert, animated: true, completion: nil)
  }
  
  func alertBoxOKCancel(title: String?, message: String?, tapped: (() -> Void)?, cancelTapped: (() -> Void)?) {
    let messageString = NSMutableAttributedString.init(string: /message, attributes: [NSAttributedString.Key.font : Fonts.SFProTextMedium.ofSize(14),
                                                                              NSAttributedString.Key.foregroundColor: Color.textBlack90.value])
    
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: { (_) in
      cancelTapped?()
    }))
    alert.setValue(messageString, forKey: "attributedMessage")
    alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: { (_) in
      tapped?()
    }))
    present(alert, animated: true, completion: nil)
  }
  
  func navigate(lat: Double, lng: Double) {
    actionSheet(for: [VCLiteral.NAVIGATE_AR.localized,
                      VCLiteral.NAVIGATE_GOOGLE_MAPS.localized], title: VCLiteral.NAVIGATE_TITLE.localized, message: nil, tapped: { [weak self] (tappedString) in
                        switch tappedString {
                        case VCLiteral.NAVIGATE_AR.localized:
                          self?.getARDirections(lat: lat, lng: lng)
                        case VCLiteral.NAVIGATE_GOOGLE_MAPS.localized:
                          self?.openGoogleMaps(lat: String(lat), lng: String(lng))
                        default: break
                        }
    })
  }
  
  func getARDirections(lat: Double, lng: Double) {
    //    refreshControl.startAnimating()
    
    let mapLocation = MKMapItem.init(placemark: MKPlacemark.init(coordinate: CLLocationCoordinate2D.init(latitude: lat, longitude: lng), addressDictionary: nil))
    
    let request = MKDirections.Request()
    request.source = MKMapItem.forCurrentLocation()
    request.destination = mapLocation
    request.requestsAlternateRoutes = false
    
    let directions = MKDirections(request: request)
    
    directions.calculate(completionHandler: { response, error in
      //      defer {
      //        DispatchQueue.main.async { [weak self] in
      //          self?.refreshControl.stopAnimating()
      //        }
      //      }
      if let error = error {
        return print("Error getting directions: \(error.localizedDescription)")
      }
      guard let response = response else {
        return
      }
      
      if response.routes.count > 0 {
        
        DispatchQueue.main.async { [weak self] in
          guard let self = self else {
            return
          }
          
          let arNavigationVC = StoryboardScene.Other.ARNavigationVC.instantiate()
          arNavigationVC.routes = response.routes
          self.presentVC(arNavigationVC)
        }
      } else {
        self.alertBoxOKCancel(title: AlertType.validationFailure.title, message: VCLiteral.NO_ROUTE_FOUND.localized, tapped: {
          
        }, cancelTapped: {
          
        })
      }
      
    })
  }
  
  func openGoogleMaps(lat: String, lng: String) {
    if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
      UIApplication.shared.open(URL(string: "comgooglemaps://?saddr=&daddr=\(/lat),\(/lng)&directionsmode=driving")!)
    } else {
      UIApplication.shared.open(URL(string: "http://itunes.apple.com/us/app/id585027354")!)
    }
  }

  //MARK:- Present PopUp
  func presentPopUp(_ destVC: UIViewController) {
    addChild(destVC)
    destVC.view.frame = view.frame
    view.addSubview(destVC.view)
    destVC.didMove(toParent: self)
  }
  
  //MARK:- PopUps start
  func startPopUpWithAnimation() {
    view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
    view.alpha = 0.0
    UIView.animate(withDuration: 0.25, animations: {
      self.view.alpha = 1.0
      self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
    })
  }
  
  //MARK:- PopUp End
  func removePopUp() {
    UIView.animate(withDuration: 0.25, animations: {
      self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
      self.view.alpha = 0.0
    }, completion: {(finished: Bool) in
      if finished{
        self.view.removeFromSuperview()
      }
    })
  }
}
