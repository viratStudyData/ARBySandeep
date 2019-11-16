//
//  Toast.swift
//  AE
//
//  Created by MAC_MINI_6 on 03/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit
import SwiftEntryKit

class Toast {
  
  static let shared = Toast()
  
  func showAlert(type: AlertType, message: String) {
    var attributes = EKAttributes()
    attributes.windowLevel = .statusBar
    attributes.position = .top
    attributes.displayDuration = 1.0
    attributes.entryBackground = .color(color: type.color)
    attributes.positionConstraints.safeArea = .empty(fillSafeArea: true)
    let title = EKProperty.LabelContent.init(text: type.title, style: .init(font: Fonts.SFProDisplayBold.ofSize(18), color: UIColor.white))
    let description = EKProperty.LabelContent.init(text: message, style: .init(font: Fonts.SFProDisplayMedium.ofSize(14), color: UIColor.white))
    let simpleMessage = EKSimpleMessage.init(title: title, description: description)
    let notificationMessage = EKNotificationMessage.init(simpleMessage: simpleMessage)
    let contentView = EKNotificationMessageView(with: notificationMessage)
    SwiftEntryKit.display(entry: contentView, using: attributes)
  }
}
