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

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    }
    
    override func willActivate() {
        super.willActivate()
        
        line4Switch.setOn(UserDefaults.standard.bool(forKey: UserDefaultsKeys.m4))
        
        line6Switch.setOn(UserDefaults.standard.bool(forKey: UserDefaultsKeys.m6))
    }

    @IBAction func onLine4SwitchChange(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: UserDefaultsKeys.m4)
    }

    @IBAction func onLine6SwitchChange(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: UserDefaultsKeys.m6)
    }
}
