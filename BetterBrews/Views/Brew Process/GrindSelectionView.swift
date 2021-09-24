//
//  GrindSelectionView.swift
//  BetterBrews
//
//  Created by Colby Haskell on 8/11/21.
//

import SwiftUI

struct GrindSelectionView: View {
    @Binding var showSelf: Bool
    @ObservedObject var newBrew: NewBrew
    
    var body: some View {
        
        grindInfoForm
    }
    
//MARK: - Form
    var grindInfoForm: some View {
        //UITableView.appearance().backgroundColor = UIColor(named: "tan")
        ZStack {
            Color("lightTan")
                .ignoresSafeArea()
            VStack {
                Spacer()
                Form {
                    grindSizePicker
                    coffeeAmountSection
                    nextButton
                }
                .navigationTitle("Start Grinding")
                .navigationBarTitleDisplayMode(.inline)
                Spacer()
            }
            .edgesIgnoringSafeArea(.bottom)
        }
            //.colorScheme(.dark)
    }
    
    var fillRecommendedButton: some View {
        Section(header: Text("Use Recommended").padding(.top).foregroundColor(Color("black"))) {
            Button(action: { newBrew.brew.coffeeAmountString = "30.0"}) {
                Text("Use Recommended")
                    .foregroundColor(Color("gold"))
            }
        }
        .listRowBackground(viewConstants.listRowBackground)
    }
    
    var grindSizePicker: some View {
        Section(header: Text("Grind Size").foregroundColor(Color("black"))) {
            HStack {
                Picker("Grind Size", selection: $newBrew.brew.grindSize) {
                    Text("Extra Fine").tag(GrindSize.extraFine)
                    Text("Fine").tag(GrindSize.fine)
                    Text("Medium").tag(GrindSize.medium)
                    Text("Coarse").tag(GrindSize.coarse)
                }
                .pickerStyle(SegmentedPickerStyle())
                .foregroundColor(Color("gold"))
                Image(systemName: "info.circle")
                    .foregroundColor(viewConstants.linkColor)
            }
            .foregroundColor(.white)
        }
        .listRowBackground(viewConstants.listRowBackground)

    }
    
    var coffeeAmountSection: some View {
        Section(header: Text("Coffee Measured").foregroundColor(Color("black"))) {
            HStack {
                TextField("Measure Coffee", text: $newBrew.brew.coffeeAmountString)
                    .accentColor(.white)
                    .foregroundColor(.white)
                    .keyboardType(.decimalPad)
                    //.preferredColorScheme()
                Button(action: { }) {
                    Image(systemName: "info.circle")
                        .foregroundColor(viewConstants.linkColor)
                }
            }
            Picker("Measurement", selection: $newBrew.brew.coffeeUnit) {
                Text("Grams").tag(CoffeeUnit.g)
                Text("Tbsps").tag(CoffeeUnit.tbsp)
            }
            .pickerStyle(SegmentedPickerStyle())
        }
        .listRowBackground(viewConstants.listRowBackground)
    }
    
    var nextButton: some View {
        Section {
            NavigationLink("Water Info", destination: WaterTempView(showSelf: $showSelf, newBrew: newBrew))
            .foregroundColor(Color("gold"))
                .disabled(newBrew.brew.coffeeAmount == nil)
        }
        .listRowBackground(viewConstants.listRowBackground)
    }
    
    struct viewConstants {
        static let listRowBackground = Color("brown")
        static let linkColor = Color("gold")
    }
}

enum GrindSize: String {
    case coarse = "Coarse"
    case medium = "Medium"
    case fine = "Fine"
    case extraFine = "Extra Fine"
}

struct GrindSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            GrindSelectionView(showSelf: .constant(true), newBrew: NewBrew(BrewEquipment(id: 0, name: "Aeropress", type: "Immersion", notes: "good", estTime: 6, filters: ["Immersion"])))
        }
    }
}
