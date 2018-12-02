//
//  LineRowType.swift
//  RatpMetro WatchKit Extension
//
//  Created by Kévin TURMEL on 01/12/2018.
//  Copyright © 2018 Kévin TURMEL. All rights reserved.
//

import Foundation
import WatchKit

class LineRowType : NSObject {
  @IBOutlet weak var lineGroup: WKInterfaceGroup!
  @IBOutlet weak var titleLabel: WKInterfaceLabel!
  @IBOutlet weak var lineImage: WKInterfaceImage!
  @IBOutlet weak var firstLabel: WKInterfaceLabel!
  @IBOutlet weak var secondLabel: WKInterfaceLabel!
}
