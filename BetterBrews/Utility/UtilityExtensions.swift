//
//  UtilityExtensions.swift
//  BetterBrews
//
//  Created by Colby Haskell on 8/20/21.
//

import Foundation

//Adds function to capitalize first letter of a string
extension String {
    func capitalizingFirstLetter() -> String {
      return prefix(1).uppercased() + self.lowercased().dropFirst()
    }

    mutating func capitalizeFirstLetter() {
      self = self.capitalizingFirstLetter()
    }
}

extension Date {
    func stringFromDate() -> String {
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM dd,yyyy"
        return dateFormatterPrint.string(from: self)
    }
}

extension Double {
    func secondsFromDecimal() -> Int {
        let percentMinute: Double = Double(Int(self*100)%100)/100
        return Int(percentMinute * 60)
    }
}
