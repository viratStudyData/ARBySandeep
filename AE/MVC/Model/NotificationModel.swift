//
//  NotificationModel.swift
//  AE
//
//  Created by MAC_MINI_6 on 15/05/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import Foundation

class NotificationData: Codable {
  var count: Int?
  var data: [Notification]?
}

class Notification: Codable {
  var userId: UserData?
  var businessId: Business?
  var message: String?
  var createdDate: Int64?
  var _id: String?
  var notificationType: NotificationType?
  var title: String?
  var isRead: Bool?
  var requestId: String?
  
}
