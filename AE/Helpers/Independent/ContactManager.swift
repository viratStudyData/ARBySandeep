//
//  ContactManager.swift
//  AE
//
//  Created by MAC_MINI_6 on 04/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit
import ContactsUI
import PhoneNumberKit

class ContactNumber {
  var number: ContactSynced?
  var name: String?
  var image: UIImage?
  
  init(_number: ContactSynced?, _name: String?) {
    number = _number
    name = _name
  }
}

enum CMStrings: String {
  case PERMISSION_DENIED = "CMStrings_PERMISSION_DENIED"
  case SETTINGS = "CMStrings_SETTINGS"
  case CANCEL = "CMStrings_CANCEL"
  case MESSAGE = "CMStrings_MESSAGE"
  
  var localized: String {
    return NSLocalizedString(self.rawValue, comment: "")
  }
}

class ContactManager {
  
  static let shared = ContactManager()
  private let store = CNContactStore()
  private var contacts: [ContactNumber]? {
    didSet {
      syncContactsWithISO()
    }
  }
  private var didAccessChanged: IS_ACCESS_GRANTED?
  private var didPickContacts: DID_PICK_CONTACTS?
  
  typealias IS_ACCESS_GRANTED = (_ granted: Bool?) -> Void
  typealias DID_PICK_CONTACTS = (_ contacts: [ContactNumber]?) -> Void
  
  
  private func syncContactsWithISO() {
    var tempContacts = contacts
    tempContacts?.sort{ (/$0.name).localizedCaseInsensitiveCompare(/$1.name) == ComparisonResult.orderedAscending }
    let phoneNumberKit = PhoneNumberKit()
    
    let phoneNumber = try? phoneNumberKit.parse(tempContacts?.map({/$0.number?.phoneNo}) ?? [])
    
    tempContacts?.forEach({ (number) in
      if let index: Int = phoneNumber?.firstIndex(where: {/$0.numberString == /number.number?.phoneNo}) {
        number.number?.ISO = phoneNumber?[index].regionID
      }
    })
    
    tempContacts?.removeAll(where: {/$0.number?.ISO == ""})
    
    didPickContacts?(tempContacts)
  }
  
  private func requestAccess() {
    store.requestAccess(for: .contacts) { (granted, error) in
      if let err = error {
        print("Error \(err.localizedDescription)")
        return
      }
      self.didAccessChanged?(granted)
      if granted {
        self.fetchContacts()
      } else {
        self.didAccessChanged?(false)
      }
    }
  }
  
  func checkAutorization(_ accessChanged: IS_ACCESS_GRANTED?, pickContacts: DID_PICK_CONTACTS?) {
    let authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
    didAccessChanged = accessChanged
    didPickContacts = pickContacts
    switch authorizationStatus {
    case .authorized:
      fetchContacts()
    case .notDetermined:
      didAccessChanged?(false)
      fetchContacts()
    case .denied, .restricted:
      didAccessChanged?(false)
      showAlert()
    @unknown default:
        fatalError()
    }
  }
  
  private func showAlert() {
    let alert = UIAlertController.init(title: CMStrings.PERMISSION_DENIED.localized, message: CMStrings.MESSAGE.localized, preferredStyle: .alert)
    alert.addAction(UIAlertAction.init(title: CMStrings.CANCEL.localized, style: .destructive, handler: { (_) in
      self.didAccessChanged?(false)
    }))
    alert.addAction(UIAlertAction.init(title: CMStrings.SETTINGS.localized, style: .default, handler: { (_) in
      UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
    }))
    UIApplication.topVC()?.present(alert, animated: true, completion: nil)
  }
  
  private func fetchContacts() {
    let request = CNContactFetchRequest(keysToFetch: [CNContactGivenNameKey, CNContactPhoneNumbersKey, CNContactThumbnailImageDataKey] as [CNKeyDescriptor])
    
    do {
      var tempContacts = [ContactNumber]()
      try store.enumerateContacts(with: request) { (contact, stopPointer) in
        if let number = contact.phoneNumbers.first?.value {
          if contact.givenName != "" {
            let contactModel = ContactNumber(_number: ContactSynced.init(number.stringValue, nil), _name: contact.givenName)
            if let data = contact.thumbnailImageData {
              contactModel.image = UIImage(data: data)
            }
            
            tempContacts.append(contactModel)
          }
        }
      }
      contacts = tempContacts
    } catch let error {
      print("Enumeration Error\(error.localizedDescription)")
    }
  }
  
}
