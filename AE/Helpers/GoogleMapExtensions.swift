//
//  GoogleMapExtensions.swift
//  AE
//
//  Created by MAC_MINI_6 on 23/05/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit
import GoogleMaps

//MARK:- GMSMapView Extension
extension GMSMapView {
  func getCenterCoordinate() -> CLLocationCoordinate2D {
    let centerPoint = center
    let centerCoordinate = projection.coordinate(for: centerPoint)
    return centerCoordinate
  }
  
  func getTopCenterCoordinate() -> CLLocationCoordinate2D {
    // to get coordinate from CGPoint of your map
    let topCenterCoor = convert(CGPoint(x: frame.size.width / 2.0, y: 0), from: self)
    let point = projection.coordinate(for: topCenterCoor)
    return point
  }
  
  func getRadius() -> CLLocationDistance {
    
    let centerCoordinate = getCenterCoordinate()
    // init center location from center coordinate
    let centerLocation = CLLocation(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude)
    let topCenterCoordinate = getTopCenterCoordinate()
    let topCenterLocation = CLLocation(latitude: topCenterCoordinate.latitude, longitude: topCenterCoordinate.longitude)
    
    let radius = CLLocationDistance(centerLocation.distance(from: topCenterLocation))
    
    return round(radius)
  }
}
