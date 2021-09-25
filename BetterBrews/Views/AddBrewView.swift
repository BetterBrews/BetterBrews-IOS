//
//  AddBrewView.swift
//  BetterBrews
//
//  Created by Colby Haskell on 8/12/21.
//

import SwiftUI

struct AddBrewView: View {
    @Environment(\.presentationMode) var presentation
    @EnvironmentObject var brews: BrewEquipmentList
    
    @State private var newBrewName: String = ""
    @State private var newBrewType: String = ""
    @State private var newBrewNotes: String = ""
    @State private var newBrewTime: String = ""
    
    private var estBrewTime: Int {
        Int(newBrewTime)!
    }
    
    var body: some View {
        Form {
            Section {
                TextField("Brewer Name", text: $newBrewName)
                TextField("Type", text: $newBrewType)
                TextField("Time in Minutes", text: $newBrewTime)
            }
            .accentColor(AppStyle.accentColor)
            .foregroundColor(.white)
            .listRowBackground(Color.black)
            Section {
                TextField("Notes", text: $newBrewNotes)
            }
            .foregroundColor(.white)
            .listRowBackground(Color.black)
            Button(action: finish) {
                HStack {
                    Spacer()
                    Text("Add New Brew")
                        .foregroundColor(AppStyle.accentColor)
                    Spacer()
                }
            }
            .listRowBackground(Color.black)
            .disabled(Int(newBrewTime) == nil)
        }
        .accentColor(AppStyle.accentColor)
    }
    
    func finish() {
        brews.addEquipment(name: newBrewName, type: newBrewType, notes: newBrewNotes, estTime: estBrewTime)
        self.presentation.wrappedValue.dismiss()
    }
}

struct AddBrewView_Previews: PreviewProvider {
    static var previews: some View {
        AddBrewView()
    }
}
