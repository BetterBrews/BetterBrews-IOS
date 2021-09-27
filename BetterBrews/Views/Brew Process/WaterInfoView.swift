//
//  WaterInfoView.swift
//  BetterBrews
//
//  Created by Colby Haskell on 8/11/21.
//

import SwiftUI

struct WaterInfoView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var showBrewStack: Bool
    @ObservedObject var newBrew: NewBrew
    @State var showRatingView = false
    
    var reviewMode = false
    
    var body: some View {
        UITableView.appearance().backgroundColor = UIColor(named: "tan")
        
        return
            ZStack {
                Color("lightTan")
                    .ignoresSafeArea()
                NavigationLink("Time and Rating Selection", destination: RatingView(showBrewStack: $showBrewStack, newBrew: newBrew), isActive: $showRatingView)
                    .opacity(0)
                    .background(Color("lightTan"))
                Form {
                    Section(header: Text("Water Temperature").foregroundColor(Color("black"))) {
                        TextField("Temperature", text: $newBrew.brew.temperatureString)
                            .keyboardType(.decimalPad)
                            .foregroundColor(.white)
                            .accentColor(AppStyle.accentColor)
                        Picker("Units", selection: $newBrew.brew.temperatureUnit) {
                            Text("Celcius").tag(TemperatureUnit.celcius)
                            Text("Farenheit").tag(TemperatureUnit.farenheit)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    .listRowBackground(viewConstants.listRowBackground)
                    Section(header: Text("Water Measured").foregroundColor(Color("black"))) {
                        TextField("Amount", text: $newBrew.brew.waterVolumeString)
                            .keyboardType(.decimalPad)
                            .foregroundColor(.white)
                            .accentColor(AppStyle.accentColor)
                        Picker("Units", selection: $newBrew.brew.waterVolumeUnit) {
                            Text("mL").tag(WaterVolumeUnit.mL)
                            Text("Grams").tag(WaterVolumeUnit.g)
                            Text("Cups").tag(WaterVolumeUnit.cups)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    .listRowBackground(viewConstants.listRowBackground)
                    Section(header: Text("Next").foregroundColor(Color("black"))) {
                        nextButton
                    }
                    .listRowBackground(viewConstants.listRowBackground)
                }
                .foregroundColor(Color("black"))
                .padding(.top)
                .background(Color("tan"))
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Prepare Water")
    }
    
    var nextButton: some View {
        ZStack {
            Button(action: nextPressed) {
                HStack {
                    Text(reviewMode ? "Review" : "Time and Rating Selection")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
            }
            .foregroundColor(viewConstants.linkColor)
            .opacity((newBrew.brew.temperatureString == "" || newBrew.brew.waterVolumeString == "") ? 0.7 : 1)
        }
    }
    
    func nextPressed() {
        if(reviewMode) {
            presentationMode.wrappedValue.dismiss()
        }
        else {
            showRatingView.toggle()
        }
    }
    
    //MARK: - Functions
    func fillRecommended() {
        newBrew.brew.temperatureString = "100"
        newBrew.brew.waterVolumeString = "500"
    }
    
    struct viewConstants {
        static let listRowBackground = Color("brown")
        static let linkColor = Color("gold")
    }
}

struct WaterTempView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WaterInfoView(showBrewStack: .constant(true), newBrew: NewBrew(BrewEquipment(id: 0, name: "Aeropress", type: "Immersion", notes: "good", estTime: 6, filters: ["Immersion"])))
        }
    }
}
