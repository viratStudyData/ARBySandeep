//
//  LocationManager.swift
//  AE
//
//  Created by MAC_MINI_6 on 26/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//


import UIKit
import CoreLocation

struct LocationManagerData {
    var latitude: Double = 0
    var longitude: Double = 0
    var isLocationAllowed: Bool = false
}

typealias DidChangeLocation = ((_ location: LocationManagerData) -> ())
typealias LocationAuthChanged = ((_ isLocationAllowed: Bool) -> ())

enum LocationStrings: String {
    case LOC_PERMISSION_DENIED_TITLE = "LOC_PERMISSION_DENIED_TITLE"
    case LOC_PERMISSION_DENIED_MESSAGE = "LOC_PERMISSION_DENIED_MESSAGE"
    
    var localized: String {
        return NSLocalizedString(self.rawValue, comment: "")
    }
}

class LocationManager: NSObject {
    
    static let shared = LocationManager()
    
    private let lmInstance = CLLocationManager()
    var locationData = LocationManagerData()
    private var changeLocationBlock: DidChangeLocation?
    private var locationAuthChanged: LocationAuthChanged?
    
    func isLocationEnabled(auth: LocationAuthChanged?) {
        locationAuthChanged = auth
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                locationAuthChanged?(false)
            case .authorizedAlways, .authorizedWhenInUse:
                locationAuthChanged?(true)
            @unknown default:
                break
            }
        } else {
            locationAuthChanged?(false)
        }
    }
    
    func startTrackingUser(didChangeLocation: DidChangeLocation? = nil) {
        lmInstance.delegate = self
        lmInstance.desiredAccuracy = kCLLocationAccuracyBest
        lmInstance.requestAlwaysAuthorization()
        lmInstance.startUpdatingLocation()
        //Background Features
        lmInstance.allowsBackgroundLocationUpdates = true
        lmInstance.startMonitoringSignificantLocationChanges()
        changeLocationBlock = didChangeLocation
    }
    
    func showSettingAlert() {
        UIApplication.topVC()?.alertBoxOKCancel(title: LocationStrings.LOC_PERMISSION_DENIED_TITLE.localized, message: LocationStrings.LOC_PERMISSION_DENIED_MESSAGE.localized, tapped: {
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        }, cancelTapped: {
            self.locationAuthChanged?(false)
        })
    }
    
}

//MARK:- CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            lmInstance.startUpdatingLocation()
            locationData.isLocationAllowed = true
            locationAuthChanged?(true)
        case .denied, .restricted:
            showSettingAlert()
            locationData.isLocationAllowed = false
            locationAuthChanged?(false)
        case .notDetermined:
            lmInstance.startUpdatingLocation()
            lmInstance.requestAlwaysAuthorization()
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationData.isLocationAllowed = true
        let latLng = locations.last?.coordinate
        locationData = LocationManagerData(latitude: /latLng?.latitude, longitude: /latLng?.longitude, isLocationAllowed: true)
        
        //Static lat lngs
//        locationData = LocationManagerData(latitude: 28.7041, longitude: 77.1025, isLocationAllowed: true)
      
        changeLocationBlock?(locationData)
        SocketIOManager.shared.updateLocation(for: .AppActive, lat: locationData.latitude, long: locationData.longitude)
    }
}
