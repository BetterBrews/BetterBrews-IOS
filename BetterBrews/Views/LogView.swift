//
//  LogView.swift
//  BetterBrews
//
//  Created by Colby Haskell on 8/11/21.
//

import SwiftUI

struct LogView: View {
    //MARK: State
    @EnvironmentObject var brews: EquipmentList
    @EnvironmentObject var settings: GlobalSettings
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "date", ascending: false)])
    private var pastBrews: FetchedResults<PastBrew>
    
    @State private var filter = EquipmentFilter.allBrews
    @State private var editing = false

    
    private enum EquipmentFilter: String, CaseIterable {
        case allBrews = "All Brews"
        case aeropress = "Aeropress"
        case espresso = "Espresso"
    }
    
    var body: some View {
            VStack(spacing: 0) {
                toolbar
                if(pastBrews.isEmpty) {
                    emptyBrewList
                }
                else {
                    VStack {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(pastBrews) { brew in
                                    listDateHeader(brew.date)
                                    HStack(alignment: .center) {
                                        if(editing) {
                                            deleteButton(brew)
                                        }
                                        logCard(brew)
                                            .padding()
                                    }
                                    .transition(.slide)
                                    if (brew != pastBrews.last) {
                                        Divider()
                                            .background(Color("black"))
                                            .padding(.horizontal)
                                            
                                    }
                                }
                            }
                            .animation(.easeInOut)
                        }
                    }
                }
            }
            .background(Color("tan").ignoresSafeArea())
            .navigationBarTitle("Brew Log")
            //.navigationBarTitleDisplayMode(.inline)
    }
    
    func deleteButton(_ brew: PastBrew) -> some View {
        Image(systemName: "minus.circle.fill")
            .font(.title2)
            .foregroundColor(Color(UIColor.systemRed))
            .shadow(radius: 10)
            .padding(.leading)
            .onTapGesture {
                BrewsManager.deleteBrew(brew)
            }
    }
    
    func listDateHeader(_ brewDate: Date?) -> some View {
        return
            Text(brewDate!.stringFromDate())
                .font(.title)
                .bold()
                .foregroundColor(Color("black"))
                .padding([.top, .leading])
                .padding(.horizontal)
    }
    
    var emptyBrewList: some View {
        VStack {
            Spacer()
            Text("No brews yet...")
                .font(.headline)
            Spacer()
        }
    }
    
    var toolbar: some View {
        HStack {
            filterMenu
            Spacer()
            Button(editing ? "Done" : "Edit") {
                self.editing.toggle()
            }
            .foregroundColor(Color("lightBrown"))
        }
        .padding()
        .background(Color("lightTan").ignoresSafeArea())
    }
    
    var filterMenu: some View {
        Menu(content: {
            ForEach(EquipmentFilter.allCases, id: \.self) { filterName in
                Button(filterName.rawValue) {
                    filter = filterName
                }
                .disabled(filter == filterName)
            }
        } ) {
            RoundedButton(buttonText: filter.rawValue, buttonImage: "line.horizontal.3.circle", isSelected: true, action: {})
        }
    }
    
    func logCard(_ brew: PastBrew) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: constants.logCardCornerRadius)
                .foregroundColor(Color("brown"))
            logCardList(brew)
        }
        .transition(AnyTransition.move(edge: .trailing))
    }
    
    func logCardList(_ brew: PastBrew) -> some View {
        var temperatureUnitString: String {
            switch(brew.temperatureUnit) {
            case .celcius:
                return String(format:"%@C", "\u{00B0}")
            case .farenheit:
                return String(format:"23%@F", "\u{00B0}")
            }
        }
        return
            VStack(alignment: .leading) {
                HStack {
                    Text(brew.equipment ?? "Brew")
                        .bold()
                        .font(.title2)
                        .foregroundColor(Color("gold"))
                    Spacer()
                }
                .padding()
                VStack {
                    logCardRow("Grind Size:", brew.grind?.capitalizingFirstLetter() ?? "Grind", showDivider: true)
                    logCardRow("Coffee Amount:", (String(brew.coffeeAmount) + brew.coffeeUnitString!), showDivider: true)
                    logCardRow("Water Amount:", (String(brew.waterAmount) + brew.waterVolumeUnitString!), showDivider: true)
                    logCardRow("Water Temperature:", (String(brew.waterTemp) + temperatureUnitString), showDivider: true)
                    logCardRow("Brew Time:", String(format: "%2d:%02d", brew.timeMinutes(), brew.timeSeconds()), showDivider: true)
                    logCardRow("Rating:", "TODO", showDivider: true)
                }
                .padding([.horizontal, .bottom])
            }
            .padding()
    }
    
    func logCardRow(_ label: String, _ value: String, showDivider: Bool) -> some View {
        VStack {
            HStack {
                Text(label)
                Spacer()
                Text(value)
            }
            .foregroundColor(Color(.white))
            if(showDivider) {
                logCardDivider
            }
        }
    }
    
    var logCardDivider: some View {
        Divider()
            .background(Color(.white))
    }
    
    func delete(_ indexSet: IndexSet) {
        BrewsManager.deleteBrew(pastBrews[indexSet.first!])
    }
    
    private struct constants {
        static let logCardCornerRadius: CGFloat = 20
    }
}


struct LogView_Previews: PreviewProvider {
    static let brewList = EquipmentList([BrewEquipment(id: 0, name: "Aero", type: "good", notes: "good", estTime: 5)])
    static let globalSettings = GlobalSettings()
    
    static var previews: some View {
        NavigationView {
            LogView()
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
                .environmentObject(brewList)
                .environmentObject(globalSettings)
        }
    }
}
