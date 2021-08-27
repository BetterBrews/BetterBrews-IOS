//
//  AddBeanView.swift
//  BetterBrews
//
//  Created by Colby Haskell on 8/17/21.
//

import SwiftUI

struct AddBeanView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var roasterName = ""
    @State private var beanName = ""
    @State private var roastType = RoastType.medium
    @State private var datePurchased = Date()
    
    //TODO:
    //Make fields optional
    
    var body: some View {
        UITableView.appearance().backgroundColor = UIColor(named: "lightTan")
        
        return
            Form {
                Section(header: Text("Name").foregroundColor(viewConstants.headerColor)) {
                    TextField("Roaster", text: $roasterName)
                    TextField("Bean Name", text: $beanName)

                }
                
                Section(header: Text("Roast Type").foregroundColor(viewConstants.headerColor)) {
                    Picker("Roast", selection: $roastType) {
                        Text("Dark").tag(RoastType.dark)
                        Text("Medium").tag(RoastType.medium)
                        Text("Light").tag(RoastType.light)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                Section {
                    Button(action: {
                        BeanManager.addBean(name: beanName, roaster: roasterName, roast: roastType, date: datePurchased)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Spacer()
                            Text("Add Bean")
                            Spacer()
                        }
                    }
                    .disabled(roasterName == "" || beanName == "")
                }
                Section {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Spacer()
                            Text("Cancel")
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                }
            }
            .padding(.top)
            .background(Color("lightTan"))
            .colorScheme(.dark)
    }
    
    struct viewConstants {
        static let headerColor = Color("black")
    }
}

struct AddBeanView_Previews: PreviewProvider {
    static var previews: some View {
        Color("lightTan")
            .ignoresSafeArea()
            .sheet(isPresented: .constant(true), content: {
                AddBeanView()
            })
    }
}
