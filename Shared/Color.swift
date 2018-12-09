//
//  Color.swift
//  RatpMetro
//
//  Created by Kévin TURMEL on 09/12/2018.
//  Copyright © 2018 Kévin TURMEL. All rights reserved.
//

import Foundation
import WatchKit

///
/// MARK: -
///
/// - SeeAlso: https://iosdevcenters.blogspot.com/2016/03/extension-for-hex-color-code-to-uicolor.html
///
extension UIColor {
  func intFromHexString(_ hex: String) -> UInt32 {
    var hexInt: UInt32 = 0
    // Create scanner
    let scanner: Scanner = Scanner(string: hex)
    // Tell scanner to skip the # character
    scanner.charactersToBeSkipped = CharacterSet(charactersIn: "#")
    // Scan hex value
    scanner.scanHexInt32(&hexInt)
    return hexInt
  }
  
  func hexToColor(hex: String, alpha: CGFloat? = 1.0) -> UIColor {
    let hexint = Int(self.intFromHexString(hex))
    let red = CGFloat((hexint & 0xff0000) >> 16) / 255.0
    let green = CGFloat((hexint & 0xff00) >> 8) / 255.0
    let blue = CGFloat((hexint & 0xff) >> 0) / 255.0
    let alpha = alpha!
    let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)

    return color
  }
}

public enum RatpColorHex: String {
  case M4 = "#AE287A", M6 = "#73B77B"
}

public class RatpColor {
  let line: RatpLine
  
  init(_ line: RatpLine) {
    self.line = line
  }
  
  func getUIColor() -> UIColor? {
    var ratpHex: RatpColorHex?

    switch line {
    case .m4:
      ratpHex = RatpColorHex.M4
    default:
      ratpHex = RatpColorHex.M6
    }

    guard let hex = ratpHex else { return nil }

    return UIColor().hexToColor(hex: hex.rawValue)
  }
}
