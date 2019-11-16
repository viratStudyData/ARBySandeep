//
//  PhoneServices.swift
//  AE
//
//  Created by MAC_MINI_6 on 29/05/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import Foundation
import PhoneNumberKit //Third Party
import MessageUI // MFMailComposer // MessageComposeVC

class PhoneServices: NSObject {
  
  func call(to number: String) {
    do {
      let phoneNo = try PhoneNumberKit().parse(number)
      if let url = URL.init(string: "telprompt://" + phoneNo.numberString.replacingOccurrences(of: " ", with: "-")) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
      }
    } catch {
      print(error.localizedDescription)
    }
  }
  
  func openSettings() {
     UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
  }
  
  
  func sendMessage(to numbers: [String], messageBody: String?) {
    let controller = MFMessageComposeViewController()
    controller.body = messageBody
    controller.recipients = numbers
    controller.messageComposeDelegate = self
    UIApplication.topVC()?.presentVC(controller)
  }
  
  func mail(to emails: [String], subject: String? = nil, messageBody: String? = nil, isHTML: Bool? = false) {
    let mc: MFMailComposeViewController = MFMailComposeViewController()
    if let emailSubject = subject {
      mc.setSubject(emailSubject)
    }
    if let body = messageBody {
      mc.setMessageBody(body, isHTML: isHTML ?? false)
    }
    mc.mailComposeDelegate = self
    mc.setToRecipients(emails)
    UIApplication.topVC()?.presentVC(mc)
  }
}

extension PhoneServices: MFMailComposeViewControllerDelegate {
  internal func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
    controller.dismissVC()
  }
}

extension PhoneServices: MFMessageComposeViewControllerDelegate {
  func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
    controller.dismissVC()
  }
}
