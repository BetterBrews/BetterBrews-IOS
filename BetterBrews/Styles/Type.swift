import SwiftUI
import Foundation

class FontWeight {
  static let Normal = "Montserrat-Regular"
  static let Bold = "Montserrat-Bold"
  static let SemiBold = "Montserrat-SemiBold"
}

let headerOne = Font.custom(
  FontWeight.Bold,
  size: 30.scaledpx
)
let headerTwo = Font.custom(
  FontWeight.Bold,
  size: 20.scaledpx
)
let headerThree = Font.custom(
  FontWeight.Bold,
  size: 18.scaledpx
)
let headerFour = Font.custom(
  FontWeight.SemiBold,
  size: 14.scaledpx
)
let mobileParagraphType = Font.custom(
  FontWeight.Normal,
  size: 16.scaledpx
)

let mobileTextXSmall = Font.custom(
  FontWeight.Normal,
  size: 13.scaledpx
)

extension Int {
  /// Converts to a scalable pixel unit that can be used across devices
  var scaledpx: CGFloat { CGFloat(self) * 1 }  // factor }
}
