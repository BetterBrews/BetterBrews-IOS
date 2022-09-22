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

class Brew {
    var equipmentName: String
    var bean: Bean?
    var brewTime: Double?                                               // [mins]
    var coffeeUnit: CoffeeUnit = loadDefaultCoffeeUnit()
    var temperatureUnit: TemperatureUnit = loadDefaultTemperatureUnit()
    var waterVolumeUnit: WaterVolumeUnit = loadDefaultWaterVolumeUnit()
    
    var temperatureString: String = ""
    var coffeeAmountString: String = ""
    var waterVolumeString: String = ""
    
    var notes: String = ""
    
    //Rating from 1-10, 0 = Not Yet Rated
    var rating: Int = 0
    
    var grindSize: GrindSize = GrindSize.medium
    
    var waterTemp: Double? {
        Double(temperatureString)
    }
    var waterVolume: Double? {
        Double(waterVolumeString)
    }
    var coffeeAmount: Double? {
        Double(coffeeAmountString)
    }

    var grindSizeString: String? {
        grindSize.rawValue
    }
    
    // Copy pastBrew data into Brew data structure
    init(pastBrew: PastBrew) {
        equipmentName = pastBrew.equipment!
        bean = pastBrew.bean
        brewTime = pastBrew.brewTime
        coffeeUnit = pastBrew.coffeeUnit
        temperatureUnit = pastBrew.temperatureUnit
        waterVolumeUnit = pastBrew.waterVolumeUnit
        notes = pastBrew.notes ?? " "
        rating = Int(pastBrew.rating)
        grindSize = GrindSize(rawValue: pastBrew.grind ?? GrindSize.medium.rawValue) ?? GrindSize.medium
        temperatureString = String(pastBrew.waterTemp)
        coffeeAmountString = String(pastBrew.coffeeAmount)
        waterVolumeString = String(pastBrew.waterAmount)
    }
    
    init(_ method: String) {
        equipmentName = method
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

