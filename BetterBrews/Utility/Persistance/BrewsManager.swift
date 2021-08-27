//
//  BrewsManager.swift
//  BetterBrews
//
//  Created by Colby Haskell on 8/16/21.
//

import Foundation
import CoreData

struct BrewsManager {
    private static var viewContext = PersistenceController.viewContext
    
    //Create a new brew with date as current date
    static func saveBrew(_ brew: Brew) {
        let newBrew = PastBrew(context: viewContext)
        newBrew.date = Date()
        newBrew.equipment = brew.brewEquipment
        newBrew.bean = brew.bean!
        //Coffee
        newBrew.coffeeAmount = brew.coffeeAmount!
        newBrew.grind = brew.grindSizeString!
        //Water
        newBrew.waterTemp = brew.waterTemp!
        newBrew.waterAmount = brew.waterAmount!
        
        newBrew.brewTime = Double(brew.brewTime!)
        
        //Units
        newBrew.coffeeUnitString = brew.coffeeUnit.rawValue
        newBrew.waterVolumeUnitString = brew.waterVolumeUnit.rawValue
        print(brew.coffeeUnit.rawValue)
        newBrew.temperatureUnitString = brew.temperatureUnit.rawValue

        PersistenceController.saveContext()
        print("Brew Created and Saved")
    }
    
    //Delete specified past brew
    static func deleteBrew(_ brew: PastBrew) {
        viewContext.delete(brew)
        PersistenceController.saveContext()
        print("Past brew deleted")
    }
    
    //Clear all Past Brews
    static func clearLog() {
        let entity = "PastBrew"
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)

        do {
            let entities = try viewContext.fetch(fetchRequest)
            for entity in entities {
                viewContext.delete(entity as! NSManagedObject)
            }
        } catch let error as NSError {
            print(error)
        }
        print("Cleared Log")
        PersistenceController.saveContext()
    }
}
