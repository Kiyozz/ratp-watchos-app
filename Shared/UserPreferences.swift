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
  private let m4Station = "line4_station"
  private let m6Station = "line6_station"
  private let m4StationName = "line4_station_name"
  private let m6StationName = "line6_station_name"
  
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
  
  var stationM4: String {
    set {
      UserDefaults.standard.set(newValue, forKey: m4Station)
    }
    
    get {
      return UserDefaults.standard.string(forKey: m4Station) ?? "montparnasse+bienvenue"
    }
  }
  
  var stationM6: String {
    set {
      UserDefaults.standard.set(newValue, forKey: m6Station)
    }
    
    get {
      return UserDefaults.standard.string(forKey: m6Station) ?? "montparnasse+bienvenue"
    }
  }
  
  var stationM4Name: String {
    set {
      UserDefaults.standard.set(newValue, forKey: m4StationName)
    }
    
    get {
      return UserDefaults.standard.string(forKey: m4StationName) ?? "Montparnasse Bienvenue"
    }
  }
  
  var stationM6Name: String {
    set {
      UserDefaults.standard.set(newValue, forKey: m6StationName)
    }
    
    get {
      return UserDefaults.standard.string(forKey: m6StationName) ?? "Montparnasse Bienvenue"
    }
  }
}
