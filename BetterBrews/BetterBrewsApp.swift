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
                .environment(\.colorScheme, .dark)
                .environmentObject(brewList)
                .environmentObject(globalSettings)
        }
    }
    init() {
        setUIAppearance()
    }
    
    func setUIAppearance() {
        //Navigation Bar
        UINavigationBar.appearance().backgroundColor = UIColor(named: "lightTan")
        UINavigationBar.appearance().barTintColor = UIColor(named: "lightTan")
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor(named: "black")!]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(named: "black")!]
        UINavigationBar.appearance().tintColor = AppStyle.UIBodyTextColor
        
        //Form Appearance
        UITableView.appearance().backgroundColor = UIColor(named: "tan")
        UITableViewCell.appearance().backgroundColor = UIColor(named: "tan")
        UITableView.appearance().separatorColor = UIColor(named: "lightTan")
    }
}
