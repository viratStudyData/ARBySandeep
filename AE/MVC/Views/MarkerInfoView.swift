//
//  MarkerInfoView.swift
//  AE
//
//  Created by MAC_MINI_6 on 22/05/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit
import CoreLocation

class MarkerInfoView: UIView {
  @IBOutlet weak var imgView: UIImageView!
  @IBOutlet weak var lblTitle: UILabel!
  @IBOutlet weak var lblSubTitle: UILabel!
  @IBOutlet weak var lblAddress: UILabel!
  @IBOutlet weak var lblDistance: UILabel!
  
//  private var swipeGesture = UISwipeGestureRecognizer.init(target: self, action: #selector(handleSwipeGesture) )
  override init(frame: CGRect) {
    super.init(frame: frame)
//    swipeGesture.direction = .down
//    addGestureRecognizer(swipeGesture)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
//    swipeGesture.direction = .down
//    addGestureRecognizer(swipeGesture)
  }
  
  var item: MixedMapData? {
    didSet {
      let latLng = LocationManager.shared.locationData
      let currentLocation = CLLocation(latitude: latLng.latitude, longitude: latLng.longitude)
      switch item?.markerType ?? .Business {
      case .Business:
        imgView.setImageKF(item?.business?.logoUrl?.thumbnail)
        lblTitle.text = /item?.business?.name
        lblSubTitle.text = item?.business?.businessType
        lblAddress.text = /item?.business?.addressDetails?.address
        let distance = CLLocationDistance(currentLocation.distance(from: CLLocation(latitude: /item?.business?.addressDetails?.coordinates?.last, longitude: /item?.business?.addressDetails?.coordinates?.first) ))
        lblDistance.text = String(format: VCLiteral.KM_AWAY.localized, "\((distance / 1000).rounded(toPlaces: 2))")
      case .GlobalPlace:
        imgView.setImageKF(item?.globalPlace?.imageUrl?.thumbnail, placeHolder: nil)
        lblTitle.text = /item?.globalPlace?.name
        lblSubTitle.text = ""
        lblAddress.text = /item?.globalPlace?.location?.address
        let location = CLLocation(latitude: /item?.globalPlace?.location?.lat, longitude: /item?.globalPlace?.location?.long)
        let distance = CLLocationDistance(currentLocation.distance(from: location))
        lblDistance.text = String(format: VCLiteral.KM_AWAY.localized, "\((distance / 1000).rounded(toPlaces: 2))")
      case .User:
        imgView.setImageKF(item?.user?.imageUrl?.thumbnail, placeHolder: #imageLiteral(resourceName: "ic_profile_placeholder"))
        lblTitle.text = /item?.user?.name
        var subTitleString = ""
        if let email = item?.user?.email {
          subTitleString = email
        }
        if let phoneNo = item?.user?.phoneNumber {
          let number = "+\(/phoneNo.countryCode)-\(/phoneNo.phoneNo)"
          subTitleString = subTitleString == "" ? number : "\(subTitleString) | \(number)"
        }
        lblSubTitle.text = subTitleString
        let location = CLLocation(latitude: /item?.user?.latLong?.last, longitude: /item?.user?.latLong?.first)
        let distance = CLLocationDistance(currentLocation.distance(from: location))
        lblDistance.text = String(format: VCLiteral.KM_AWAY.localized, "\((distance / 1000).rounded(toPlaces: 2))")
        CLGeocoder().reverseGeocodeLocation(location) { [weak self] (placeMarks, error) in
          self?.lblAddress.text = /placeMarks?.first?.name
        }
      }
    }
  }
  
  @objc func handleSwipeGesture() {
   (UIApplication.topVC() as? MapVC)?.hideInfo(for: item)
  }
  
  @IBAction func btnAction(_ sender: UIButton) {
    switch item?.markerType ?? .Business {
    case .Business:
      let latitude = /item?.business?.addressDetails?.coordinates?.last
      let longitude = /item?.business?.addressDetails?.coordinates?.first
      if sender.tag == 1 {
        UIApplication.topVC()?.getARDirections(lat: latitude, lng: longitude)
      } else {
        UIApplication.topVC()?.openGoogleMaps(lat: String(latitude), lng: String(longitude))
      }
    case .User:
      let latitude = /item?.user?.latLong?.last
      let longitude = /item?.user?.latLong?.first
      if sender.tag == 1 {
        UIApplication.topVC()?.getARDirections(lat: latitude, lng: longitude)
      } else {
        UIApplication.topVC()?.openGoogleMaps(lat: String(latitude), lng: String(longitude))
      }
    case .GlobalPlace:
      let latitude = /item?.globalPlace?.location?.lat
      let longitude = /item?.globalPlace?.location?.long
      if sender.tag == 1 {
        UIApplication.topVC()?.getARDirections(lat: latitude, lng: longitude)
      } else {
        UIApplication.topVC()?.openGoogleMaps(lat: String(latitude), lng: String(longitude))
      }
    }
  }
}
