//
//  Debug.swift
//  RatpMetro
//
//  Created by Kévin TURMEL on 02/12/2018.
//  Copyright © 2018 Kévin TURMEL. All rights reserved.
//

public class Debug {
  var from: String?
  
  init(from: String?) {
    self.from = from
  }
  
  func log(_ message: Any) {
    if let from = from {
      print("[\(from)] - \(message)")
      
      return
    }
    
    print(message)
  }
}
