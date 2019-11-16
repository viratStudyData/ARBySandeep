//
//  MapVC.swift
//  AE
//
//  Created by MAC_MINI_6 on 16/05/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit
import GoogleMaps

class MapVC: BaseVC {

  @IBOutlet weak var mapView: GMSMapView!
  @IBOutlet weak var tfSearch: UITextField!
  @IBOutlet weak var markerInfoViewBottom: NSLayoutConstraint!
  @IBOutlet weak var markerInfoView: MarkerInfoView!
  @IBOutlet var btnFlags: [UIButton]!
  
  private var items = [MixedMapData]() {
    didSet {
      if items.count == 0 {
        zIndex = 0
        markers = []
      }
    }
  }
  private var mapData: MapData?
  private var pageNo = 0
  private var zIndex = 0
  private var markers = [GMSMarker]()
  private var currentLocationMarker = GMSMarker()
  private var mapFlag: MapFlag = .ALL
  
  //MARK:- Clustering Properties
//  private let iconGenerator = GMUDefaultClusterIconGenerator()
//  private let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
//  private var renderer: GMUDefaultClusterRenderer!
//  private var clusterManager: GMUClusterManager!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    mapStyling()
    
    markerInfoView.isHidden = true
    markerInfoViewBottom.constant = -208
    tfSearch.delegate = self

    let swipeGesture = UISwipeGestureRecognizer.init(target: markerInfoView.self, action: #selector(markerInfoView.handleSwipeGesture))
    swipeGesture.direction = .down
    markerInfoView.addGestureRecognizer(swipeGesture)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(true)
    LocationManager.shared.startTrackingUser { [weak self] (latLng) in
      self?.currentLocationMarker.appearAnimation = .pop
      self?.currentLocationMarker.position = CLLocationCoordinate2D(latitude: latLng.latitude, longitude: latLng.longitude)
      self?.currentLocationMarker.icon = #imageLiteral(resourceName: "ic_my_location")
      self?.currentLocationMarker.map = self?.mapView
    }
  }
  
  @IBAction func btnAction(_ sender: UIButton) {
    markerInfoView.handleSwipeGesture()
    if sender.titleColor(for: .normal) == Color.textWhite.value {
      mapFlag = .ALL
      sender.backgroundColor = Color.backgroundWhite.value
      sender.setTitleColor(Color.textBlue.value, for: .normal)
      mapAPIRefresh()
      return
    }
    mapFlag = BtnMapFlag(rawValue: sender.tag)?.flag ?? .ALL
    btnFlags.forEach({
      let uiProperty = BtnMapFlag(rawValue: $0.tag)?.uiProperty(isSelected: $0 == sender)
      $0.backgroundColor = uiProperty?.backColor
      $0.setTitleColor(uiProperty?.textColor, for: .normal)
    })
    mapAPIRefresh()
  }
}

//MARK:- VCFuncs
extension MapVC {
  //MARK:- Map Styling
  func mapStyling(){
    do {
      // Set the map style by passing the URL of the local file.
      if let styleURL = Bundle.main.url(forResource: "GMSStyle", withExtension: "json") {
        mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
      } else {
        NSLog("Unable to find style.json")
      }
    } catch {
      NSLog("One or more of the map styles failed to load. \(error)")
    }
    
    let camera = GMSCameraPosition.camera(withLatitude: LocationManager.shared.locationData.latitude,
                                          longitude: LocationManager.shared.locationData.longitude,
                                          zoom: 16)
    mapView.camera = camera
    mapView.delegate = self
    mapView.settings.myLocationButton = true
  }
  
  //MARK:- Get Markers API
  func getMapDataAPI(latitude: Double?, longitude: Double?, radius: Double?, nextPageURL: String?) {
    EP_Other.mapDataListing(radius: String(/radius), latitude: String(/latitude), longitude: String(/longitude), pageNo: String(pageNo), search: tfSearch.text, flag: mapFlag, nextPageUrl: nextPageURL).request(success: { [weak self] (response) in
      let responseData = (response as? MapData)
      self?.mapData = responseData
      let newItems = MixedMapData.getMixedDataNewItemsOnly(self?.items, responseData)
      self?.items = (self?.items ?? []) + newItems
      self?.addMarkers(newItems: newItems)
      if /responseData?.nextPage {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
          self?.pageNo = /self?.pageNo + 1
          self?.getMapDataAPI(latitude: latitude, longitude: longitude, radius: radius, nextPageURL: responseData?.nextPageUrl)
        })
      } else {
        self?.pageNo = 0
      }
    }) { (error) in
      
    }
  }
  
  //MARK:- Show marker Info View
  private func showInfo(for markerData: MixedMapData?) {
    markerInfoView.isHidden = false
    markerInfoViewBottom.constant = 0
    markerInfoView.item = markerData
    
    UIView.animate(withDuration: 0.2, animations: { [weak self] in
      self?.view.layoutSubviews()
    })
  }
  
  //MARK:- Hide marker Info View
  func hideInfo(for markerData: MixedMapData?) {
    guard let index = items.firstIndex(where: {$0 == markerData}) else {
      return
    }
    switch items[index].markerType {
    case .Business, .GlobalPlace:
      markers[index].icon = #imageLiteral(resourceName: "ic_location")
    case .User:
      let markerView = UserMarker(frame: CGRect(x: 0, y: 0, width: 59, height: 65))
      markerView.item = markerData?.user
      markers[index].iconView = markerView
    }
    markerInfoViewBottom.constant = -208
    
    UIView.animate(withDuration: 0.2, animations: { [weak self] in
      self?.view.layoutSubviews()
    }) { [weak self] (_) in
      self?.markerInfoView.isHidden = true
    }
  }
  
  //MARK:- To add markers at CLLocationCoordinate2D
  func addMarkers(newItems: [MixedMapData]) {
    for itemObj in newItems {
      let marker = GMSMarker()
      marker.appearAnimation = .pop
      switch itemObj.markerType {
      case .Business:
        marker.position = CLLocationCoordinate2D(latitude: /itemObj.business?.addressDetails?.coordinates?.last, longitude: /itemObj.business?.addressDetails?.coordinates?.first)
        marker.icon = #imageLiteral(resourceName: "ic_location")
      case .User:
        marker.position = CLLocationCoordinate2D(latitude: /itemObj.user?.latLong?.last, longitude: /itemObj.user?.latLong?.first)
        let markerView = UserMarker(frame: CGRect(x: 0, y: 0, width: 59, height: 65))
        marker.iconView = markerView
        markerView.item = itemObj.user
      case .GlobalPlace:
        marker.position = CLLocationCoordinate2D(latitude: /itemObj.globalPlace?.location?.lat, longitude: /itemObj.globalPlace?.location?.long)
        marker.icon = #imageLiteral(resourceName: "ic_location")
      }
      zIndex = zIndex + 1
      marker.zIndex = Int32(zIndex)
      marker.tracksViewChanges = true
      markers.append(marker)
      marker.map = mapView
    }
    
    if /tfSearch.text != "" { // Searching keyword
      handleSearchingMapBounds()
    }
  }
  
  //MARK:- To show markers in specific bounds visible
  func handleSearchingMapBounds() {
    if pageNo > 0 {
      return
    }
    
    var bounds = GMSCoordinateBounds()
    markers.forEach {
      bounds = bounds.includingCoordinate($0.position)
    }
    let cameraUpdate = GMSCameraUpdate.fit(bounds, withPadding: 24)
    mapView.animate(with: cameraUpdate)
  }
  
  //MARK:- Clear mapview anf fresh hit API
  func mapAPIRefresh() {
    items = []
    pageNo = 0
    mapData = nil
    mapView.clear()
    let center = mapView.getCenterCoordinate()
    getMapDataAPI(latitude: center.latitude, longitude: center.longitude, radius: mapView.getRadius(), nextPageURL: nil)
  }
}

//MARK:- GMSMapView Delegate
extension MapVC: GMSMapViewDelegate {
  //MARK:- Called when map become idle after dragging or zooming or zoom out
  func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
    if /tfSearch.text != "" {
      return
    }
    let latitude = mapView.getCenterCoordinate().latitude
    let longitude = mapView.getCenterCoordinate().longitude
    let radius = mapView.getRadius()
    if /mapData?.nextPage &&
      radius == /mapData?.radius &&
      latitude == /mapData?.latLong?.last &&
      longitude == /mapData?.latLong?.first {
      pageNo = pageNo + 1
    } else {
      pageNo = 0
      mapData = nil
    }
//    if mapFlag == .GLOBAL {
//      items = []
//      pageNo = 0
//      mapData = nil
//      mapView.clear()
//    }
    getMapDataAPI(latitude: latitude, longitude: longitude, radius: radius, nextPageURL: mapData?.nextPageUrl)
  }
  
  func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
    mapFlag = .ALL
    hideInfo(for: markerInfoView.item)
    tfSearch.text = nil
    btnFlags.forEach {
      $0.setTitleColor(Color.textBlue.value, for: .normal)
      $0.backgroundColor = Color.backgroundWhite.value
    }
    mapAPIRefresh()
    let camera = GMSCameraPosition.camera(withLatitude: LocationManager.shared.locationData.latitude,
                                          longitude: LocationManager.shared.locationData.longitude,
                                          zoom: 16)
    mapView.animate(to: camera)
    return true
  }
  
  //MARK:- Called when tap on any marker
  func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
    for (index, _marker) in markers.enumerated() {
      switch items[index].markerType {
      case .Business:
        _marker.icon = marker == _marker ? #imageLiteral(resourceName: "ic_location_red") : #imageLiteral(resourceName: "ic_location")
      case .User:
        if marker == _marker {
          let markerViewSelected = UserMarkerSelected(frame: CGRect(x: 0, y: 0, width: 92, height: 93))
          _marker.iconView = markerViewSelected
          markerViewSelected.item = items[index].user
        } else {
          let markerView = UserMarker(frame: CGRect(x: 0, y: 0, width: 59, height: 65))
          _marker.iconView = markerView
          markerView.item = items[index].user
        }
      case .GlobalPlace:
        _marker.icon = marker == _marker ? #imageLiteral(resourceName: "ic_location_red") : #imageLiteral(resourceName: "ic_location")
      }
    }
    guard let index: Int = markers.firstIndex(where: {$0 == marker}) else {
      return false
    }
    showInfo(for: items[index])
    return true
  }
  
}

//MARK:- UITextfield Delegate
extension MapVC: UITextFieldDelegate {
  func textFieldDidBeginEditing(_ textField: UITextField) {
    hideInfo(for: markerInfoView.item)
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    mapAPIRefresh()
    textField.resignFirstResponder()
    return true
  }
}


