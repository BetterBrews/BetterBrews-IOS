//
//  AddBrewView.swift
//  BetterBrews
//
//  Created by Colby Haskell on 8/12/21.
//

import SwiftUI

struct AddBrewView: View {
    @Environment(\.presentationMode) var presentation
    @EnvironmentObject var brews: EquipmentList
    
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
                TextField("name", text: $newBrewName)
                TextField("type", text: $newBrewType)
                TextField("time", text: $newBrewTime)
                
            }
            Section {
                TextEditor(text: $newBrewNotes)
            }
            Button(action: finish) {
                Text("Add New Brew")
            }
            .disabled(Int(newBrewTime) == nil)
        }
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
