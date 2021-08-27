//
//  GlobalSettings.swift
//  BetterBrews
//
//  Created by Colby Haskell on 8/20/21.
//

import Foundation
import SwiftUI

class GlobalSettings: ObservableObject {
    @Published var coffeeUnit: CoffeeUnit
    @Published var temperatureUnit: TemperatureUnit
    @Published var waterVolumeUnit: WaterVolumeUnit
    @Published var autoStartTimer: Bool
    
    init() {
        self.coffeeUnit = CoffeeUnit.g
        self.temperatureUnit = TemperatureUnit.celcius
        self.waterVolumeUnit = WaterVolumeUnit.mL
        self.autoStartTimer = true
        load()
    }
    
    func load() {
        self.coffeeUnit = CoffeeUnit(rawValue: UserDefaults.standard.string(forKey: defaultsKeys.coffeeUnit) ?? coffeeUnit.rawValue)!
        self.temperatureUnit = TemperatureUnit(rawValue: UserDefaults.standard.string(forKey: defaultsKeys.temperatureUnit) ?? temperatureUnit.rawValue)!
        self.waterVolumeUnit = WaterVolumeUnit(rawValue: UserDefaults.standard.string(forKey: defaultsKeys.temperatureUnit) ?? waterVolumeUnit.rawValue)!
        self.autoStartTimer = (UserDefaults.standard.value(forKey: defaultsKeys.autoStartTimer) as? Bool ?? true)
    }
    
    func save() {
        UserDefaults.standard.setValue(coffeeUnit.rawValue, forKey: defaultsKeys.coffeeUnit)
        UserDefaults.standard.setValue(temperatureUnit.rawValue, forKey: defaultsKeys.temperatureUnit)
        UserDefaults.standard.setValue(waterVolumeUnit.rawValue, forKey: defaultsKeys.waterVolumeUnit)
    }
    
    struct defaultsKeys {
        static let coffeeUnit = "coffeeUnit"
        static let temperatureUnit = "temperatureUnit"
        static let waterVolumeUnit = "waterVolumeUnit"
        static let autoStartTimer = "autoStartTimer"
    }
}

enum CoffeeUnit: String {
    case tbsp
    case g
}

enum TemperatureUnit: String {
    case celcius = "C"
    case farenheit = "F"
}
enum WaterVolumeUnit: String {
    case g
    case mL
    case cups
}
