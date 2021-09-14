//
//  BetterBrewsApp.swift
//  BetterBrews
//
//  Created by Colby Haskell on 8/11/21.
//

import SwiftUI

@main
struct BetterBrewsApp: App {
    let persistenceController = PersistenceController.shared
    let brewList = BrewEquipmentList()
    let globalSettings = GlobalSettings()
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(brewList)
                .environmentObject(globalSettings)
        }
    }
    init() {
        
        #if arch(i386) || arch(x86_64)
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
          NSLog("Document Path: %@", documentsPath)
        #endif
        
        setUIAppearance()
    }
    
    func setUIAppearance() {
        UINavigationBar.appearance().backgroundColor = UIColor(named: "lightTan")
        UINavigationBar.appearance().barTintColor = UIColor(named: "lightTan")
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor(named: "black")!]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(named: "black")!]
        UINavigationBar.appearance().tintColor = AppStyle.UIBodyTextColor
        
        UITableView.appearance().backgroundColor = UIColor(named: "tan")
        UITextView.appearance().backgroundColor = .clear
    }
}
