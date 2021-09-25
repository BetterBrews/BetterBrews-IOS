//
//  Brew.swift
//  BetterBrews
//
//  Model to store data for brew before creating record in core data context
//  Brew -> PastBrew(in context)
//
//  Created by Colby Haskell on 8/16/21.
//

import Foundation

struct Brew {
    var equipmentName: String
    var bean: Bean?
    var brewTime: Double?
    var coffeeUnit: CoffeeUnit = loadDefaultCoffeeUnit()
    var temperatureUnit: TemperatureUnit = loadDefaultTemperatureUnit()
    var waterVolumeUnit: WaterVolumeUnit = loadDefaultWaterVolumeUnit()
    
    var temperatureString: String = ""
    var coffeeAmountString: String = ""
    var waterAmountString: String = ""
    
    var notes: String = ""
    
    //Value from 1-10, default is 0
    var rating: Int = 0
    
    var grindSize: GrindSize = GrindSize.medium
    
    var waterTemp: Double? {
        Double(temperatureString)
    }
    var waterAmount: Double? {
        Double(waterAmountString)
    }
    var coffeeAmount: Double? {
        Double(coffeeAmountString)
    }

    var grindSizeString: String? {
        grindSize.rawValue
    }
    
    init(_ method: BrewEquipment) {
        equipmentName = method.name
    }
    
    static func loadDefaultCoffeeUnit() -> CoffeeUnit {
        return CoffeeUnit(rawValue: UserDefaults.standard.string(forKey: defaultsKeys.coffeeUnit) ?? CoffeeUnit.g.rawValue)!
    }
    
    static func loadDefaultWaterVolumeUnit() -> WaterVolumeUnit {
        return WaterVolumeUnit(rawValue: UserDefaults.standard.string(forKey: defaultsKeys.waterVolumeUnit) ?? WaterVolumeUnit.mL.rawValue)!
    }
    
    static func loadDefaultTemperatureUnit() -> TemperatureUnit {
        return TemperatureUnit(rawValue: UserDefaults.standard.string(forKey: defaultsKeys.temperatureUnit) ?? TemperatureUnit.celcius.rawValue)!
    }
    
    var temperatureUnitString: String {
        switch(self.temperatureUnit) {
        case .celcius:
            return String(format:"%@C", "\u{00B0}")
        case .farenheit:
            return String(format:"%@F", "\u{00B0}")
        }
    }
    
    
}

