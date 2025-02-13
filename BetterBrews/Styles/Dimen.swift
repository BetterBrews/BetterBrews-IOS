import Foundation
import SwiftUI

let smallCornerDimen = 8.dimenpx
let mediumCornerDimen = 16.dimenpx
let largeCornerDimen = 24.dimenpx
let extraLargeCornerDimen = 48.dimenpx

extension Int {
  /**
   Convert an integer to a scalable pixel unit.

   This will ensure proper proportions across various screen sizes

   - Returns: The converted dimensions in pixels
   */
  public var dimenpx: CGFloat { CGFloat(self) * factor }

}

/**
 * This is designed  to convert pixel sizes from figma canvas with a height of 844
 */
private func getFactor() -> CGFloat {
  if UIDevice.current.orientation.isPortrait {
    return CGFloat(Double(UIScreen.main.bounds.width)) / 844.0
  } else {
    return CGFloat(Double(UIScreen.main.bounds.height)) / 844.0
  }
}

private var factor: CGFloat = getFactor()
