//
//  UserDefaultsKeys.swift
//  RatpMetro WatchKit Extension
//
//  Created by Kévin TURMEL on 28/11/2018.
//  Copyright © 2018 Kévin TURMEL. All rights reserved.
//

import Foundation

public struct UserPreferences {
  private let m4 = "line4_active"
  private let m6 = "line6_active"
  
  var m4Active: Bool {
    set {
      UserDefaults.standard.set(newValue, forKey: m4)
    }
    
    get {
      return UserDefaults.standard.bool(forKey: m4)
    }
  }
  
  var m6Active: Bool {
    set {
      UserDefaults.standard.set(newValue, forKey: m6)
    }
    
    get {
      return UserDefaults.standard.bool(forKey: m6)
    }
  }
}
