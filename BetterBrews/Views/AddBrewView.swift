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
            Section {
                TextField("Notes", text: $newBrewNotes)
            }
            Button(action: finish) {
                Text("Add New Brew")
            }
            .disabled(Int(newBrewTime) == nil)
            .accentColor(AppStyle.accentColor)
        }
        .colorScheme(.dark)
    }
    
    func finish() {
        brews.addBrew(name: newBrewName, type: newBrewType, notes: newBrewNotes, estTime: estBrewTime)
        self.presentation.wrappedValue.dismiss()
    }
}

struct AddBrewView_Previews: PreviewProvider {
    static var previews: some View {
        AddBrewView()
    }
}
