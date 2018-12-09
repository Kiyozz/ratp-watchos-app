//
//  OptionStationLineInterfaceController.swift
//  RatpMetro WatchKit Extension
//
//  Created by Kévin TURMEL on 08/12/2018.
//  Copyright © 2018 Kévin TURMEL. All rights reserved.
//

import WatchKit
import Foundation

class OptionStationLineInterfaceController: WKInterfaceController {
  @IBOutlet weak var buttonsTable: WKInterfaceTable!
  
  let debug = Debug(from: "OptionStationLineInterfaceController")
  let lines = [RatpLine.m4, RatpLine.m6]

  var preferences = UserPreferences()
  var stationForLine = [RatpLine:(String, String)]()
  var delegate: OptionsInterfaceController?
  
  override func awake(withContext context: Any?) {
    super.awake(withContext: context)
    
    debug.log("awake")
    
    if let context = context as? OptionsInterfaceController {
      delegate = context
    }
    
    updateTable()
  }
  
  override func contextForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable, rowIndex: Int) -> Any? {
    debug.log("contextForSegue")
    
    guard let controller = table.rowController(at: rowIndex) as? OptionStationLineRowType else { return nil }

    return ["line": controller.line, "controller": self]
  }
  
  func willDismiss() {
    debug.log("willDismiss")
    
    for (line, (slug, name)) in stationForLine {
      switch line {
      case .m4:
        preferences.stationM4 = slug
        preferences.stationM4Name = name
      case .m6:
        preferences.stationM6 = slug
        preferences.stationM6Name = name
      }
    }
    
    updateTable()
  }
  
  private func trunkText(_ text: String) -> String {
    let length = text.count
    let suffix = length > 10 ? "..." : ""
    
    return "\(text.prefix(10))\(suffix)"
  }
  
  private func updateTable() {
    buttonsTable.setNumberOfRows(2, withRowType: "OptionStationLineRowType")

    for i in 0..<buttonsTable.numberOfRows {
      guard let controller = buttonsTable.rowController(at: i) as? OptionStationLineRowType else {
        return
      }
      
      var lineName = ""
      
      switch lines[i] {
      case .m4:
        lineName = preferences.stationM4Name
      case .m6:
        lineName = preferences.stationM6Name
      }
      
      controller.button.setTitle("Ligne \(lines[i].rawValue) - \(trunkText(lineName))")
      controller.line = lines[i]
    }
  }
}
