//
//  MessageModel.swift
//  AE
//
//  Created by MAC_MINI_6 on 22/06/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import Foundation

class MessageSubModel: Codable {
  var count: Int?
  var data: [Message]?
}

class Message: Codable {
  var createdOn: Int64?
  var senderId: UserData?
  var conversationId: String?
  var messageType: MESSAGE_TYPE?
  var _id: String
  var isSent: Bool?
  var viewType: String?
  var receiverId: UserData?
  var __v: Int?
  var fileUrl: ImageURL?
  var isDelivered: Bool?
}
