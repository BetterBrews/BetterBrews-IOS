//
//  Persistence.swift
//  BetterBrews
//
//  Created by Colby Haskell on 8/11/21.
//

import CoreData

struct PersistenceController {
    static var viewContext = shared.container.viewContext
    
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<5 {
            let newItem = Bean(context: viewContext)
            newItem.roaster = "Carrabassett Valley Coffee"
            newItem.name = "Jamaica Me Crazy"
            
            let newBrew = PastBrew(context: viewContext)
            newBrew.equipment = "Aeropress"
            newBrew.bean = newItem
            newBrew.brewTime = 5
            newBrew.coffeeAmount = 5
            newBrew.date = Date(timeIntervalSinceNow: TimeInterval(-24*3600))
            newBrew.grind = "coarse"
            newBrew.coffeeUnit = CoffeeUnit.g
            newBrew.waterVolumeUnit = WaterVolumeUnit.mL
            newBrew.temperatureUnit = TemperatureUnit.celcius
        }
        for _ in 0..<5 {
            let newItem = Bean(context: viewContext)
            newItem.roaster = "44 North"
            newItem.name = "Royal Tar"
            
            let newBrew = PastBrew(context: viewContext)
            newBrew.equipment = "Hario V60"
            newBrew.bean = newItem
            newBrew.brewTime = 3
            newBrew.coffeeAmount = 32.5
            newBrew.date = Date()
            newBrew.grind = "fine"
            newBrew.coffeeUnit = CoffeeUnit.g
            newBrew.waterVolumeUnit = WaterVolumeUnit.mL
            newBrew.temperatureUnit = TemperatureUnit.celcius
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "BetterBrews")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                Typical reasons for an error here include:
                * The parent directory does not exist, cannot be created, or disallows writing.
                * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                * The device is out of space.
                * The store could not be migrated to the current model version.
                Check the error message to determine what the actual problem was.
                */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
    
    //Saves the current context
    static func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print(error)
        }
    }
}

