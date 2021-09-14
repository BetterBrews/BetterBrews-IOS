//
//  GlobalSettings.swift
//  BetterBrews
//
//  Created by Colby Haskell on 8/20/21.
//

import Foundation
import SwiftUI

class GlobalSettings: ObservableObject {
    public var coffeeUnit: CoffeeUnit {
        set {
            UserDefaults.standard.setValue(newValue.rawValue, forKey: defaultsKeys.coffeeUnit)
        }
        get {
            CoffeeUnit(rawValue: UserDefaults.standard.string(forKey: defaultsKeys.coffeeUnit) ?? CoffeeUnit.g.rawValue)!
        }
    }
    public var temperatureUnit: TemperatureUnit {
        set {
            UserDefaults.standard.setValue(newValue, forKey: defaultsKeys.temperatureUnit)
        }
        get {
            TemperatureUnit(rawValue: UserDefaults.standard.string(forKey: defaultsKeys.temperatureUnit) ?? TemperatureUnit.celcius.rawValue)!
        }
    }
    public var waterVolumeUnit: WaterVolumeUnit {
        set {
            UserDefaults.standard.setValue(newValue.rawValue, forKey: defaultsKeys.waterVolumeUnit)
        }
        get {
            WaterVolumeUnit(rawValue: UserDefaults.standard.string(forKey: defaultsKeys.waterVolumeUnit) ?? WaterVolumeUnit.mL.rawValue)!
        }
    }
    public var autoStartTimer: Bool {
        set {
            UserDefaults.standard.setValue(newValue, forKey: defaultsKeys.autoStartTimer)
        }
        get {
            UserDefaults.standard.bool(forKey: defaultsKeys.autoStartTimer)
        }
    }
    
    struct defaultsKeys {
        static let coffeeUnit = "coffeeUnit"
        static let temperatureUnit = "temperatureUnit"
        static let waterVolumeUnit = "waterVolumeUnit"
        static let autoStartTimer = "autoStartTimer"
    }
}
