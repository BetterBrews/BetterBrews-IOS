//
//  BeanSelectionView.swift
//  BetterBrews
//
//  Created by Colby Haskell on 8/11/21.
//

import SwiftUI

struct BeanSelectionView: View {
    //Binding to root navigationlink isActive
    @Binding var showBrewStack: Bool
    
    //BrewMethod selected from home view
    var newBrew: NewBrew
    
    //State
    @State var showDelete: Bool = false
    @State private var searchText: String = ""
    @State private var searching: Bool = false
    @State private var showAddBeanView: Bool = false
    
    var reviewMode = false

    var body: some View {
        ZStack {
            Color("lightTan")
                .ignoresSafeArea()
            VStack(spacing: 0) {
                SearchBar(text: $searchText, isEditing: $searching, placeholder: "Search")
                    .transition(.slide)
                    .colorScheme(.light)
                editBar
                ZStack {
                    Color("tan")
                        .ignoresSafeArea()
                    VStack {
                        listView
                        proTip
                    }
                }
            }
            .navigationBarItems(leading: cancelButton)
            .navigationBarBackButtonHidden(true)
            .navigationTitle("Beans")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarHidden(searching)
            /*
             *Would be nice to display inline
             */
            //.navigationBarTitleDisplayMode(.inline)
            
        }
        .background(Color("lightTan").ignoresSafeArea())
    }
    
    var editBar: some View {
        HStack {
            Button(action: editButtonPressed) {
                if(showDelete) {
                    Text("Done")
                }
                else {
                    Text("Edit")
                }
            }
            .foregroundColor(constants.toolbarIconColor)
            Spacer()
            addButton
        }
        .padding()
    }
    
    func editButtonPressed() {
        withAnimation(.easeInOut) {
            showDelete.toggle()
        }
    }
    
    //MARK: - Bean List
    //View will create proper fetch request when search text changes
    var listView: some View {
        let filter = searchText
        
        var fetchRequest: FetchRequest<Bean> {
            if(filter.isEmpty) {
                return FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)], predicate: NSPredicate(value: true))
            }
            else {
                return FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)], predicate: NSPredicate(format: "name CONTAINS %@", filter))
            }
        }
        
        return resultsView(showSelf: $showBrewStack, beans: fetchRequest, newBrew: newBrew, showDelete: $showDelete, reviewMode: reviewMode)
    }
    
    //View will dynamically update with filtered results from search text
    struct resultsView: View {
        @Environment(\.presentationMode) var presentationMode
        @Binding var showSelf: Bool
        @FetchRequest var beans: FetchedResults<Bean>
        @ObservedObject var newBrew: NewBrew
        
        @Binding var showDelete: Bool
        
        var reviewMode: Bool
        
        
        var body: some View {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(beans) { bean in
                        beanListItem(bean, reviewMode: reviewMode)
                            .transition(.slide)
                    }
                }
                .animation(.spring(), value: beans.compactMap({$0}))
            }
        }
        
        func beanListItem(_ bean: Bean, reviewMode: Bool) -> some View {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    if(reviewMode) {
                        HStack(spacing: 0) {
                            Text(bean.roaster ?? "Unknown")
                                .padding([.leading, .vertical], constants.listRowSpacing)
                            Text(" - " + (bean.name ?? "Unknown"))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .padding(constants.listRowSpacing)
                        }
                        .foregroundColor(AppStyle.accentColor)
                        .font(.headline)
                        .lineLimit(1)
                        .background(Color("brown"))
                        .onTapGesture {
                            newBrew.brew.bean = bean
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                    else {
                        NavigationLink(destination: GrindSelectionView(showBrewStack: $showSelf, newBrew: newBrew)
                                        .onAppear(perform: { newBrew.brew.bean = bean })
                        ) {
                            HStack(spacing: 0) {
                                Text(bean.roaster ?? "Unknown")
                                    .padding([.leading, .vertical], constants.listRowSpacing)
                                Text(" - " + (bean.name ?? "Unknown"))
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .padding(constants.listRowSpacing)
                            }
                            .foregroundColor(AppStyle.accentColor)
                            .font(.headline)
                            .lineLimit(1)
                        }
                        .isDetailLink(false)
                        .background(Color("brown"))
                    }
                    if(showDelete) {
                        Button("Delete") {
                            withAnimation(.easeInOut) {
                                deleteBean(bean: bean)
                            }
                        }
                        .foregroundColor(.white)
                        .padding(constants.listRowSpacing)
                        .background(Color(UIColor.systemRed))
                        .transition(.move(edge: .trailing))
                    }
                }
                if(bean != beans.last) {
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
    
    @ViewBuilder var proTip: some View {
        if(!searching) {
            Text("Pro Tip: The best beans are always the freshest beans!")
                .font(.caption)
                .foregroundColor(Color("black"))
        }
    }
    
    //MARK: - Toolbar
    
    var toolbarTitle: some View {
        ZStack {
            Color("brown")
        }
    }
    
    var cancelButton: some View {
        Button("Cancel") {
            showBrewStack = false
        }
        .foregroundColor(constants.toolbarIconColor)
    }
    
    var addButton: some View {
        Button(action: { showAddBeanView.toggle() }) {
            Image(systemName: "plus")
                .foregroundColor(constants.toolbarIconColor)
        }
        .sheet(isPresented: $showAddBeanView, content: {
            AddBeanView().colorScheme(.dark)
        })
    }
    
    //MARK: - Constants
    private struct constants {
        static let toolbarIconColor: Color = Color("lightBrown")
        static let listRowSpacing: CGFloat = 12
    }
}

struct BeanSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BeanSelectionView(showBrewStack: .constant(true), newBrew: NewBrew(BrewEquipment(id: 0, name: "Aeropress", type: "Immersion", notes: "good", estTime: 6, filters: ["Immersion"])))
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
