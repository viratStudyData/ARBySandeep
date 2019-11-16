//
//  ARNavigationVC.swift
//  AE
//
//  Created by MAC_MINI_6 on 06/06/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit
import MapKit
import SceneKit
import ARKit

class ARNavigationVC: UIViewController {

  @IBOutlet weak var sceneLocationView: SceneLocationView!
  @IBOutlet weak var mapView: MKMapView!
  
  var business: Business?
  var routes: [MKRoute]? // Polyline path
  private var updateUserLocationTimer: Timer?
  private var userAnnotation: MKPointAnnotation?
  private var locationEstimateAnnotation: MKPointAnnotation?
  private var centerMapOnUserLocation: Bool = true

  
  override func viewDidLoad() {
    super.viewDidLoad()
    sceneLocationView.showAxesNode = false
    sceneLocationView.showFeaturePoints = true
  
    addSceneModels()
    
    updateUserLocationTimer = Timer.scheduledTimer(
      timeInterval: 0.5,
      target: self,
      selector: #selector(ARNavigationVC.updateUserLocation),
      userInfo: nil,
      repeats: true)
    
    routes?.forEach { mapView.addOverlay($0.polyline) }
    
    mapView.delegate = self
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(true)
    sceneLocationView.run()
    
  }
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(true)
    sceneLocationView.pause()
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    guard let touch = touches.first,
      let view = touch.view else { return }
    if mapView == view || mapView.subviews.contains(view) {
      centerMapOnUserLocation = false
    } else {
      let location = touch.location(in: self.view)
      
      if location.x <= 40 {
        print("left side of the screen")
        sceneLocationView.moveSceneHeadingAntiClockwise()
      } else if location.x >= view.frame.size.width - 40 {
        print("right side of the screen")
        sceneLocationView.moveSceneHeadingClockwise()
      }
    }
  }
  
  @IBAction func btnCancelAction(_ sender: UIButton) {
    dismissVC()
  }
  
}


//MARK:- VCFuncs
extension ARNavigationVC {
  
  /// Adds the appropriate ARKit models to the scene.  Note: that this won't
  /// do anything until the scene has a `currentLocation`.  It "polls" on that
  /// and when a location is finally discovered, the models are added.
  func addSceneModels() {
    // 1. Don't try to add the models to the scene until we have a current location
    guard sceneLocationView.sceneLocationManager.currentLocation != nil else {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
        self?.addSceneModels()
      }
      return
    }
//
//    let box = SCNBox(width: 1, height: 0.2, length: 5, chamferRadius: 0.25)
//    box.firstMaterial?.diffuse.contents = UIColor.gray.withAlphaComponent(0.5)
    if let routes1 = routes {
      
      sceneLocationView.addRoutes(routes: routes1) { distance -> SCNBox in
        let box = SCNBox(width: 4, height: 0.5, length: distance, chamferRadius: 0.25)
      
        box.firstMaterial?.diffuse.contents = Color.buttonBlue.value.withAlphaComponent(0.8)
        return box
      }
      
    }
  }
  
  func buildNode(latitude: CLLocationDegrees, longitude: CLLocationDegrees,
                 altitude: CLLocationDistance, imageName: String) -> LocationAnnotationNode {
    let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    let location = CLLocation(coordinate: coordinate, altitude: altitude)
    let image = UIImage(named: imageName)!
    return LocationAnnotationNode(location: location, image: image)
  }
  
  func buildViewNode(latitude: CLLocationDegrees, longitude: CLLocationDegrees,
                     altitude: CLLocationDistance, text: String) -> LocationAnnotationNode {
    let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    let location = CLLocation(coordinate: coordinate, altitude: altitude)
    let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    label.text = text
    label.backgroundColor = .green
    label.textAlignment = .center
    return LocationAnnotationNode(location: location, view: label)
  }

  
  @objc
  func updateUserLocation() {
    guard let currentLocation = sceneLocationView.sceneLocationManager.currentLocation else {
      return
    }
    
    DispatchQueue.main.async { [weak self ] in
      guard let self = self else {
        return
      }
      
      if self.centerMapOnUserLocation {
        UIView.animate(withDuration: 0.45,
                       delay: 0,
                       options: .allowUserInteraction,
                       animations: {
                        self.mapView.setCenter(CLLocationCoordinate2D.init(latitude: currentLocation.coordinate.latitude,
                                                                           longitude: currentLocation.coordinate.longitude), animated: true)
        }, completion: { _ in
          self.centerMapOnUserLocation = false
          if let polyline = self.routes?.first?.polyline {
            self.mapView.setVisibleMapRect(polyline.boundingMapRect, edgePadding: UIEdgeInsets.init(top: 20, left: 20, bottom: 20, right:20), animated: true)
          }
        })
      }
        if let bestLocationEstimate = self.sceneLocationView.sceneLocationManager.bestLocationEstimate {
          if self.locationEstimateAnnotation == nil {
            self.locationEstimateAnnotation = MKPointAnnotation()
            self.mapView.addAnnotation(self.locationEstimateAnnotation!)
          }
          self.locationEstimateAnnotation?.coordinate = bestLocationEstimate.location.coordinate
        } else if self.locationEstimateAnnotation != nil {
          self.mapView.removeAnnotation(self.locationEstimateAnnotation!)
          self.locationEstimateAnnotation = nil
        }
    }
  }
  
}

//MARK:- MKMapView Delegate functions
extension ARNavigationVC: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    let renderer = MKPolylineRenderer(overlay: overlay)
    renderer.lineWidth = 3
    renderer.strokeColor = Color.buttonBlue.value
    
    return renderer
  }
  
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    
    return nil
  }
}
