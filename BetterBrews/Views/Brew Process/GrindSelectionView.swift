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
    @State var nextPressed = false
    
    var body: some View {
        
        grindInfoForm
    }
    
//MARK: - Form
    var grindInfoForm: some View {
        ZStack {
            Color("lightTan")
                .ignoresSafeArea()
            VStack {
                NavigationLink(destination: WaterTempView(showSelf: $showSelf, newBrew: newBrew),isActive: $nextPressed) {}
                    .opacity(0)
                    .background(Color("lightTan"))
                Form {
                    grindSizePicker
                    coffeeAmountSection
                    Section(header: Text("Next").foregroundColor(.black)) {
                        nextButton
                    }
                }
                .padding(.top)
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("Prepare Beans")
                Spacer()
            }
            .edgesIgnoringSafeArea(.bottom)
        }
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
                /*Image(systemName: "info.circle")
                    .foregroundColor(viewConstants.linkColor)
                 */
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
                /*Button(action: { }) {
                    Image(systemName: "info.circle")
                        .foregroundColor(viewConstants.linkColor)
                }*/
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
        Button(action: { nextPressed.toggle() }) {
            HStack {
                Text("Enter Water Info")
                Spacer()
                Image(systemName: "chevron.right")
            }
        }
        .opacity(newBrew.brew.coffeeAmountString == "" ? 0.7 : 1)
        .foregroundColor(Color("gold"))
        .listRowBackground(Color("brown"))
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
