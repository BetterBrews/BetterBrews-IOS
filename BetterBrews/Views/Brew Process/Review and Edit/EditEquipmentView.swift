//
//  EditEquipmentView.swift
//  BetterBrews
//
//  Created by Colby Haskell on 8/11/21.
//

import SwiftUI

struct EditEquipmentView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var equipmentList: BrewEquipmentList
    @ObservedObject var newBrew: NewBrew
    
    //State
    @State private var searchText: String = ""
    @State private var searching: Bool = false
    @State private var showAddBrewView: Bool = false

    var body: some View {
        ZStack {
            Color("lightTan")
                .ignoresSafeArea()
            VStack(spacing: 0) {
                SearchBar(text: $searchText, isEditing: $searching, placeholder: "Search")
                    .transition(.slide)
                    .colorScheme(.light)
                toolbar
                ZStack {
                    Color("tan")
                        .ignoresSafeArea()
                    VStack {
                        listView(equipmentArray: equipmentList.brewEquipment, newBrew: newBrew)
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationTitle("Edit Equipment")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarHidden(searching)
        }
        .background(Color("lightTan").ignoresSafeArea())
    }
    
    var toolbar: some View {
        HStack {
            Spacer()
            addButton
        }
        .padding()
    }
    
    //MARK: - Equipment List
    //View will dynaically update with filtered results from search text
    struct listView: View {
        @Environment(\.presentationMode) var presentationMode
        var equipmentArray: [BrewEquipment]
        var newBrew: NewBrew
        
        var body: some View {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(equipmentArray) { equipment in
                        equipmentListItem(equipment)
                            .transition(.slide)
                    }
                }
                .animation(.spring(), value: equipmentArray)
            }
        }
        
        func equipmentListItem(_ equipment: BrewEquipment) -> some View {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    HStack(spacing: 0) {
                        Text(equipment.name)
                            .padding([.leading, .vertical], constants.listRowSpacing)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .padding(constants.listRowSpacing)
                    }
                    .foregroundColor(AppStyle.accentColor)
                    .font(.headline)
                    .lineLimit(1)
                }
                .background(Color("brown"))
                .onTapGesture {
                    newBrew.brew.equipmentName = equipment.name
                    presentationMode.wrappedValue.dismiss()
                }
                if(equipment != equipmentArray.last) {
                    Divider()
                        .background(Color("gold"))
                        .padding(.horizontal)
                }
            }
        }
        
        func deleteBean(bean: Bean) {
            BeanManager.deleteBean(bean: bean)
        }
    }
    
    //MARK: - Toolbar
    
    var toolbarTitle: some View {
        ZStack {
            Color("brown")
        }
    }
    
    var addButton: some View {
        Button(action: { showAddBrewView.toggle() }) {
            Image(systemName: "plus")
                .foregroundColor(constants.toolbarIconColor)
        }
        .sheet(isPresented: $showAddBrewView, content: {
            AddBrewView()
        })
    }
    
    //MARK: - Constants
    private struct constants {
        static let toolbarIconColor: Color = Color("lightBrown")
        static let listRowSpacing: CGFloat = 12
    }
}

struct EditEquipmentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EditEquipmentView(newBrew: NewBrew(BrewEquipment(id: 0, name: "Aeropress", type: "Immersion", notes: "good", estTime: 6, filters: ["Immersion"])))
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
