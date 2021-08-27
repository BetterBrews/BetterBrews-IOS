//
//  Bean.swift
//  BetterBrews
//
//  Created by Colby Haskell on 8/14/21.
//

import Foundation

extension Bean {
    var roast: RoastType {
        get {
            return RoastType(rawValue: self.roastType) ?? .medium
        }
        set {
            self.roastType = newValue.rawValue
        }
    }
}

enum RoastType: Int64, Hashable {
    case light
    case medium
    case dark
}
