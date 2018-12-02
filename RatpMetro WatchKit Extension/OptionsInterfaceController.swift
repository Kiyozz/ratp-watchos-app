//
//  OptionsInterfaceController.swift
//  RatpMetro WatchKit Extension
//
//  Created by Kévin TURMEL on 27/11/2018.
//  Copyright © 2018 Kévin TURMEL. All rights reserved.
//

import WatchKit
import Foundation

class OptionsInterfaceController: WKInterfaceController {
  @IBOutlet weak var line4Switch: WKInterfaceSwitch!
  @IBOutlet weak var line6Switch: WKInterfaceSwitch!

  var preferences = UserPreferences()
  
  override func awake(withContext context: Any?) {
    super.awake(withContext: context)
  }
  
  override func willActivate() {
    super.willActivate()
    
    line4Switch.setOn(preferences.m4Active)
    line6Switch.setOn(preferences.m6Active)
  }
  
  @IBAction func onLine4SwitchChange(_ value: Bool) {
    preferences.m4Active = value
  }
  
  @IBAction func onLine6SwitchChange(_ value: Bool) {
    preferences.m6Active = value
  }
}
