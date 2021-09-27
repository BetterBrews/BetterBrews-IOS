//
//  SettingsView.swift
//  BetterBrews
//
//  Created by Colby Haskell on 8/11/21.
//

import SwiftUI

struct SettingsView: View {
    //MARK: State
    @EnvironmentObject var globalSettings: GlobalSettings
    @EnvironmentObject var brewEquipmentList: BrewEquipmentList
    
    init() {
        //Edit UIKit appearances
        UITableView.appearance().backgroundColor = AppStyle.UIGroupedBackgroundColor
    }
    
    var body: some View {
        ZStack {
            Color("lightTan")
                .ignoresSafeArea()
            settingsForm
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Settings")
    }
    
    var settingsForm: some View {
        Form {
            Section(header: Text("Default Measurements")) {
                Picker("Select Units", selection: $globalSettings.temperatureUnit) {
                    Text("Celcius").tag(TemperatureUnit.celcius)
                    Text("Farenheit").tag(TemperatureUnit.farenheit)
                }
                Picker("Select Units", selection: $globalSettings.waterVolumeUnit) {
                    Text("Grams").tag(WaterVolumeUnit.g)
                    Text("mL").tag(WaterVolumeUnit.mL)
                    Text("cups").tag(WaterVolumeUnit.cups)
                }
                Picker("Select Units", selection: $globalSettings.coffeeUnit) {
                    Text("Weight (g)").tag(CoffeeUnit.g)
                    Text("Volume (tbsp)").tag(CoffeeUnit.tbsp)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .colorScheme(.dark)
            .listRowBackground(viewConstants.listRowBackground)
            Section(header: Text("Clear Data")) {
                Button(action: clearLog ) {
                    Text("Clear Log")
                }
                .foregroundColor(.red)
                Button(action: clearLog ) {
                    Text("Clear Beans")
                }
                .foregroundColor(.red)
                Button(action: resetEquipment ) {
                    Text("Reset Equipment")
                }
                .foregroundColor(.red)
            }
            .listRowBackground(Color.black)
            Section(header: Text("About").foregroundColor(viewConstants.headerColor)) {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.1")
                }
            }
            .foregroundColor(.white)
            .listRowBackground(viewConstants.listRowBackground)
            Section(header: Text("Contributions").foregroundColor(viewConstants.headerColor)) {
                HStack {
                    Text("Development:")
                    Spacer()
                    Text("Colby Haskell")
                }
                HStack {
                    Text("Icon and App Design:")
                    Spacer()
                    Text("Abbie Tyler")
                }
            }
            .foregroundColor(.white)
            .listRowBackground(viewConstants.listRowBackground)
        }
        .listStyle(GroupedListStyle())
        .padding(.top)
        .foregroundColor(AppStyle.titleColor)
    }
    
    func clearLog() {
        BrewsManager.clearLog()
    }
    
    func clearBeans() {
        BeanManager.clearBeans()
    }
    
    func resetEquipment() {
        brewEquipmentList.reset()
    }
    
    struct viewConstants {
        static let headerColor = Color("black")
        static let listRowBackground = Color("brown")
        static let linkColor = Color("gold")
    }
}

struct defaultsKeys {
    static let coffeeUnit = "coffeeUnit"
    static let temperatureUnit = "temperatureUnit"
    static let waterVolumeUnit = "waterVolumeUnit"
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView()
                .environmentObject(GlobalSettings())
        }
        .preferredColorScheme(.light)
        //.preferredColorScheme(.light)
    }
}
