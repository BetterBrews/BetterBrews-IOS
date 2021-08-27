//
//  SettingsView.swift
//  BetterBrews
//
//  Created by Colby Haskell on 8/11/21.
//

import SwiftUI

struct SettingsView: View {
    //MARK: State
    @State private var settingsManager = GlobalSettings()
    @State private var autostartTimer = true
    @State private var coffeeUnitSelection = CoffeeUnit.g
    @State private var temperatureUnitSelection = TemperatureUnit.celcius
    @State private var waterVolumeUnitSelection = WaterVolumeUnit.mL
    
    var body: some View {
        //Edit UIKit appearances
        UITableView.appearance().backgroundColor = AppStyle.UIGroupedBackgroundColor
        
        let settingsForm =
            Form {
                Section(header: Text("Tutorial")) {
                    NavigationLink(destination: Text("Tutorial")) {
                        Text("How to Use BetterBrew")
                            .foregroundColor(viewConstants.linkColor)
                    }
                }
                .listRowBackground(viewConstants.listRowBackground)
                Section(header: Text("Brew Timer")) {
                    Toggle("Auto Start Timer", isOn: $autostartTimer)
                        .foregroundColor(.white)
                        .onChange(of: autostartTimer, perform: { value in
                            settingsManager.autoStartTimer = value
                            print(settingsManager.autoStartTimer)
                        })
                }
                .listRowBackground(viewConstants.listRowBackground)
                Section(header: Text("Water Measurements")) {
                    Picker("Select Units", selection: $temperatureUnitSelection) {
                        Text("Celcius").tag(TemperatureUnit.celcius)
                        Text("Farenheit").tag(TemperatureUnit.farenheit)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: temperatureUnitSelection, perform: { value in
                        settingsManager.temperatureUnit = temperatureUnitSelection
                        settingsManager.save()
                    })
                    Picker("Select Units", selection: $waterVolumeUnitSelection) {
                        Text("Grams").tag(WaterVolumeUnit.g)
                        Text("mL").tag(WaterVolumeUnit.mL)
                        Text("cups").tag(WaterVolumeUnit.cups)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: waterVolumeUnitSelection, perform: { value in
                        settingsManager.coffeeUnit = coffeeUnitSelection
                        settingsManager.save()
                    })
                }
                .listRowBackground(viewConstants.listRowBackground)
                Section(header: Text("Coffee Measurements")) {
                    Picker("Select Units", selection: $coffeeUnitSelection) {
                        Text("Weight (g)").tag(CoffeeUnit.g)
                        Text("Volume (tbsp)").tag(CoffeeUnit.tbsp)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: coffeeUnitSelection, perform: { value in
                        settingsManager.coffeeUnit = coffeeUnitSelection
                        settingsManager.save()
                    })
                }
                .listRowBackground(viewConstants.listRowBackground)
                Section(header: Text("About").foregroundColor(viewConstants.headerColor)) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0")
                    }
                    NavigationLink("Contributions", destination: Text("Contributions"))
                }
                .foregroundColor(.white)
                .listRowBackground(viewConstants.listRowBackground)
                Section(header: Text("Clear Data")) {
                    Button(action: clearLog ) {
                        Text("Clear Log")
                    }
                    .foregroundColor(Color(.red))
                    Button(action: clearLog ) {
                        Text("Clear Beans")
                    }
                    .foregroundColor(Color(UIColor.systemRed))
                }
                //.listRowBackground(viewConstants.listRowBackground)
            }
            .listStyle(GroupedListStyle())
            .padding(.top)
            .background(Color("tan"))
            .foregroundColor(AppStyle.titleColor)
            .colorScheme(.dark)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Settings")
        
        return settingsForm
    }
    
    func clearLog() {
        BrewsManager.clearLog()
    }
    
    func clearBeans() {
        BeanManager.clearBeans()
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
        }
    }
}
