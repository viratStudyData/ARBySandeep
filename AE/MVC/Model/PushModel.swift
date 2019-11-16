//
//  PushModel.swift
//  AE
//
//  Created by MAC_MINI_6 on 12/07/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import Foundation

class PushNotification: Codable {
  var notificationType: String?
  var notificationId: String?
  var title: String?
  var message: String?
  var alert: Alert?
}


class Alert: Codable {
  var body: String?
  var title: String?
}
