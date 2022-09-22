//
//  PastBrew.swift
//  This is the brew data type stored in CoreData/CloudKit
//
//  Created by Colby Haskell on 8/20/21.
//

import Foundation

extension PastBrew {
    func timeSeconds() -> Int {
        let percentSeconds = Int((self.brewTime*100).truncatingRemainder(dividingBy: 100))
        let seconds: Int = percentSeconds*60/100
        return seconds
    }
    
    func timeMinutes() -> Int {
        return Int(self.brewTime)
    }
}

extension PastBrew {
    var temperatureUnit: TemperatureUnit {
        get {
            return TemperatureUnit(rawValue: self.temperatureUnitString!)!
        }
        set {
            self.temperatureUnitString = newValue.rawValue
        }
    }
    var waterVolumeUnit: WaterVolumeUnit {
        get {
            return WaterVolumeUnit(rawValue: self.waterVolumeUnitString!)!
        }
        set {
            self.waterVolumeUnitString = newValue.rawValue
        }
    }

    var coffeeUnit: CoffeeUnit {
        get {
            return CoffeeUnit(rawValue: self.coffeeUnitString!)!
        }
        set {
            self.coffeeUnitString = newValue.rawValue
        }
    }
    
    var formattedTemperatureUnitString: String {
        switch(self.temperatureUnit) {
        case .celcius:
            return String(format:"%@C", "\u{00B0}")
        case .farenheit:
            return String(format:"%@F", "\u{00B0}")
        }
    }

}
