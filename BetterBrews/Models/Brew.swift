//
//  PastBrews.swift
//  BetterBrews
//
//  Created by Colby Haskell on 8/16/21.
//

import Foundation

struct Brew {
    //TODO: add water amount, coffee amount
    
    //Store Data for brew before creating in context
    let brewEquipment: String
    var bean: Bean?
    var brewTime: Double?
    var coffeeUnit: CoffeeUnit = loadDefaultCoffeeUnit()
    var temperatureUnit: TemperatureUnit = loadDefaultTemperatureUnit()
    var waterVolumeUnit: WaterVolumeUnit = loadDefaultWaterVolumeUnit()
    
    var temperatureString: String = ""
    var coffeeAmountString: String = ""
    var waterAmountString: String = ""
    
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
        brewEquipment = method.name
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
    
    
}

