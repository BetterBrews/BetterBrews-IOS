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
        
        //Connect Bean to Brew
        let beanRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Bean")
        beanRequest.predicate = NSPredicate(format: "name CONTAINS %@", brew.bean!.name!)
        do {
            let beans = try viewContext.fetch(beanRequest)
            let bean: Bean = beans.first.unsafelyUnwrapped as! Bean
            newBrew.bean = bean
        }
        catch {
            newBrew.bean = Bean(context: viewContext)
            newBrew.bean!.roaster = brew.bean!.roaster
            newBrew.bean!.roast = brew.bean!.roast
            newBrew.bean!.name = brew.bean!.name
        }
        
        //
        newBrew.equipment = brew.equipmentName
        //Coffee
        newBrew.coffeeAmount = brew.coffeeAmount!
        newBrew.grind = brew.grindSizeString!
        //Water
        newBrew.waterTemp = brew.waterTemp!
        newBrew.waterAmount = brew.waterAmount!
        //Brew Time
        newBrew.brewTime = Double(brew.brewTime!)
        //Units
        newBrew.coffeeUnit = brew.coffeeUnit
        newBrew.waterVolumeUnit = brew.waterVolumeUnit
        newBrew.temperatureUnit = brew.temperatureUnit
        //Rating
        newBrew.rating = Int64(brew.rating)
        
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
