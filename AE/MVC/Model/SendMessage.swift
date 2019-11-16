//
//  SendMessage.swift
//  AE
//
//  Created by MAC_MINI_6 on 21/06/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import Foundation

enum MESSAGE_TYPE: String, Codable {
  case TEXT = "TEXT"
  case IMAGE = "IMAGE"
  case VIDEO = "VIDEO"
  
  var title: VCLiteral {
    switch self {
    case .IMAGE:
      return .SENT_PHOTO
    case .VIDEO:
      return .SENT_VIDEO
    case .TEXT:
      return .UPLOADING
    }
  }
  
  var btnTitle: VCLiteral {
    switch self {
    case .IMAGE:
      return .BTN_VIEW
    case .VIDEO:
      return .BTN_PLAY
    case .TEXT:
      return .BTN_PLAY
    }
  }
}

class SendMessage: Codable {
  var receiverId: [String]?
  var message: String?
  var fileUrl: ImageURL?
  var messageType: MESSAGE_TYPE?
  
  init(ids: [String]?, _fileUrl: ImageURL?, _messageType: MESSAGE_TYPE?, _message: String? = nil) {
    receiverId = ids
    message = _message
    fileUrl = _fileUrl
    messageType = _messageType
  }
}
