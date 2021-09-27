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
    static func addBean(name: String?, roaster: String?, roast: RoastType?, date: Date?) {
        let newBean = Bean(context: PersistenceController.viewContext)
        newBean.name = name ?? "N/A"
        newBean.roaster = roaster ?? "N/A"
        newBean.roast = roast ?? RoastType.medium
        newBean.datePurchased = date ?? Date()
        PersistenceController.saveContext()
        print("Bean Saved")
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
    
    static func getBean(named name: String) throws -> Bean {
        //Connect Bean to Brew
        let beanRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Bean")
        beanRequest.predicate = NSPredicate(format: "name CONTAINS %@", name)
    
        let fetchedBean = try viewContext.fetch(beanRequest)
        let bean = fetchedBean.first.unsafelyUnwrapped as! Bean
        return bean
    }
    
    static func allBeans() -> [Bean] {
        let beanRequest = NSFetchRequest<Bean>(entityName: "Bean")
        do {
            return try viewContext.fetch(beanRequest)
        }
        catch {
            return []
        }
    }
}
