//
//  UserPreference.swift
//  AE
//
//  Created by MAC_MINI_6 on 17/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import Foundation

final class UserPreference {
  
  let DEFAULTS_KEY = "AUGMENTED_EXPERIENCE_DEFAULTS_KEY"
  
  static let shared = UserPreference()
  
  private init() {
    
  }
  
  var data : UserData? {
    get{
      return fetchData()
    }
    set{
      if let value = newValue {
        saveData(value)
      } else {
        removeData()
      }
    }
  }
  
  var firebaseToken: String?
  
  var appDefaults: AppDefault?
  
//  var locality: String?
  
  private func saveData(_ value: UserData) {
    guard let data = JSONHelper<UserData>().getData(model: value) else {
      removeData()
      return
    }
    UserDefaults.standard.set(data, forKey: DEFAULTS_KEY)
  }
  
  private func fetchData() -> UserData? {
    guard let data = UserDefaults.standard.data(forKey: DEFAULTS_KEY) else {
      return nil
    }
    return JSONHelper<UserData>().getCodableModel(data: data)
  }
  
  private func removeData() {
    UserDefaults.standard.removeObject(forKey: DEFAULTS_KEY)
  }
  
  public func updateFollowingCount(_ isFollowing: Bool) {
    let tempData = data
    tempData?.followingBusinessCount = isFollowing ? (/tempData?.followingBusinessCount + 1) : (/tempData?.followingBusinessCount - 1)
    data = tempData
  }
}

