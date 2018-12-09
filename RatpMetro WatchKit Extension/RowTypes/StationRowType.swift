//
//  StationRowType.swift
//  RatpMetro WatchKit Extension
//
//  Created by Kévin TURMEL on 09/12/2018.
//  Copyright © 2018 Kévin TURMEL. All rights reserved.
//

import Foundation
import WatchKit

class StationRowType: NSObject {
  @IBOutlet weak var nameButton: WKInterfaceButton!
  var slug: String!
  var name: String!
  var delegate: StationInterface!
  
  @IBAction func onStationClick() {
    delegate.onStationClick(slug: slug, name: name)
  }
}
