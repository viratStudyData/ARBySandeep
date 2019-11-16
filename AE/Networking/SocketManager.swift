//
//  SocketManager.swift
//  AE
//
//  Created by MAC_MINI_6 on 06/05/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import Foundation
import SocketIO

enum NameSpace: String {
  case AppActive = "/app-active"
  case AppInActive = "/app-inactive"
}

enum EventName: String {
  case nearByBusiness = "nearByBusiness"
  case nearByBusinessClientSide = "nearByBusinessClientSide"
  case sendMessage = "sendMessage"
}

class SocketIOManager: NSObject {

  static let shared = SocketIOManager()
  
  private let manager = SocketManager.init(socketURL: URL(string: APIConstant.basePath)!, config: [.log(true),
                                                                                                   .compress,
                                                                                                   .connectParams([ Keys.userId.rawValue : /UserPreference.shared.data?._id,
                                                                                                                        Keys.deviceId.rawValue: /UIDevice.current.identifierForVendor?.uuidString]),
                                                                                                   .forceNew(true)] )
  override init() {
    super.init()
  }
  
  func connect(for nameSpace: NameSpace) {
    let socket = manager.socket(forNamespace: nameSpace.rawValue)

    switch socket.status {
    case .disconnected, .notConnected:
      socket.connect()
    case .connected:
      refreshConnection(for: nameSpace)
    case .connecting:
      break
    }
    socket.connect()
  }
  
  private func refreshConnection(for nameSpace: NameSpace) {
    let socket = manager.socket(forNamespace: nameSpace.rawValue)
    socket.connect()
  }
  
  func closeConnection() {
    manager.disconnect()
  }
  
  func updateLocation(for nameSpace: NameSpace, lat: Double, long: Double) {
    let socket = manager.socket(forNamespace: nameSpace.rawValue)
    if socket.status == .disconnected || socket.status == .notConnected {
      connect(for: nameSpace)
      return
    }
    let location = [Keys.lat.rawValue: lat,
                    Keys.long.rawValue: long]

    socket.emit(EventName.nearByBusiness.rawValue, location) {

    }
  }
  
  func getNearByBusinesses(for nameSpace: NameSpace, businesses: ( (_ data: BusineesPageObject?) -> () )?) {

    let socket = manager.socket(forNamespace: nameSpace.rawValue)
    if socket.status == .disconnected || socket.status == .notConnected {
      connect(for: nameSpace)
    }

    socket.on(EventName.nearByBusinessClientSide.rawValue) { (response, ack) in

      print(response.first!)

      if /response.count == 1 {
        let respObj = JSONHelper<BusineesPageObject>().getCodableModel(data: response.last!)
        businesses?(respObj)
      }
    }
  }
  
  func sendMessage(model: SendMessage, nameSpace: NameSpace, success: (() -> Void)?) {
    let socket = manager.socket(forNamespace: nameSpace.rawValue)
    let dictionary = JSONHelper<SendMessage>().toDictionary(model: model) ?? [:]
    print("SOCKET INPUT: ", dictionary)
    socket.emit(EventName.sendMessage.rawValue, dictionary)
    success?()
  }
}
