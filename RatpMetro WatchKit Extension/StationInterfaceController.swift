//
//  StationInterfaceController.swift
//  RatpMetro WatchKit Extension
//
//  Created by Kévin TURMEL on 08/12/2018.
//  Copyright © 2018 Kévin TURMEL. All rights reserved.
//

import WatchKit
import Foundation

public protocol StationInterface {
  func onStationClick(slug: String, name: String)
}

class StationInterfaceController: WKInterfaceController, StationInterface {
  @IBOutlet weak var stationsTable: WKInterfaceTable!
  @IBOutlet weak var titleLabel: WKInterfaceLabel!
  
  let api = RatpApi()
  let debug = Debug(from: "StationInterfaceController")

  var stations: [RatpStation]?
  var line: RatpLine?
  var controller: OptionStationLineInterfaceController?
  
  var getStationsTask: URLSessionTask? {
    willSet {
      getStationsTask?.cancel()
    }
  }
  
  override func awake(withContext context: Any?) {
    super.awake(withContext: context)
    
    debug.log("awake")
    
    setTitle("")
    
    if let context = context as? Dictionary<String, Any> {
      let line = context["line"] as! RatpLine
      let controller = context["controller"] as? OptionStationLineInterfaceController
      
      self.line = line
      self.controller = controller
      titleLabel.setText("Arrêts de la ligne \(line.rawValue)")
    }
  }
  
  override func willActivate() {
    super.willActivate()
    
    debug.log("willActivate")
    
    guard let line = line else { return }
    
    getStationsTask = api.stations(forLine: line) { (stations, error) in
      if error != nil {
        print(error!)
        
        return
      }
      
      guard let stations = stations else { return }
      
      self.stations = stations
      
      self.stationsTable.setNumberOfRows(stations.count, withRowType: "StationRowType")
      
      for (index, station) in stations.enumerated() {
        guard let controller = self.stationsTable.rowController(at: index) as? StationRowType else { continue }
        
        controller.nameButton.setHidden(false)
        controller.nameButton.setTitle(station.name)
        controller.slug = station.slug
        controller.name = station.name
        controller.delegate = self
      }
    }
  }
  
  override func didDeactivate() {
    // This method is called when watch view controller is no longer visible
    super.didDeactivate()
    
    debug.log("didDeactivate")
    getStationsTask = nil
  }
  
  func onStationClick(slug: String, name: String) {
    debug.log("Click on \(slug)")
    
    guard let controller = controller else {
      self.dismiss()
      
      return
    }
    
    guard let line = line else {
      self.dismiss()
      
      return
    }
    
    controller.stationForLine[line] = (slug, name)
    controller.willDismiss()
    
    self.dismiss()
  }
}
