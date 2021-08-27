//
//  BeanManager.swift
//  BetterBrews
//
//  Created by Colby Haskell on 8/14/21.
//

import Foundation
import CoreData

class BeanManager {
    private static var viewContext = PersistenceController.viewContext
    
    //Add bean
    static func addBean(name: String, roaster: String, roast: RoastType, date: Date) {
        let newBean = Bean(context: PersistenceController.viewContext)
        newBean.name = name
        newBean.roaster = roaster
        newBean.roast = roast
        newBean.datePurchased = date
        PersistenceController.saveContext()
    }
    
    //Delete a specific bean
    static func deleteBean(bean: Bean) {
        PersistenceController.viewContext.delete(bean)
        PersistenceController.saveContext()
    }
    
    //Clear all saved beans
    static func clearBeans() {
        let entity = "Bean"
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)

        do {
            let entities = try PersistenceController.viewContext.fetch(fetchRequest)
            for entity in entities {
                viewContext.delete(entity as! NSManagedObject)
            }
        } catch let error as NSError {
            print(error)
        }
        print("Cleared Beans")
        PersistenceController.saveContext()
    }
}
