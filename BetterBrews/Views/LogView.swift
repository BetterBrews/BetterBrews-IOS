//
//  LogView.swift
//  BetterBrews
//
//  Created by Colby Haskell on 8/11/21.
//

import SwiftUI

struct LogView: View {
    //MARK: State
    @EnvironmentObject var brews: BrewEquipmentList
    @EnvironmentObject var settings: GlobalSettings
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "date", ascending: false)])
    private var pastBrews: FetchedResults<PastBrew>
    
    @State private var menuFilter = BrewEquipmentList.MenuFilter.showAll
    @State private var editing = false

    
    private var pastBrewsToShow: [PastBrew] {
        switch(menuFilter) {
        case .Favorites:
            return pastBrews.filter() { pastBrew in
                return brews.favorites.contains(where: { $0.name == pastBrew.equipment })
            }
        case .showAll:
            return pastBrews.map( { return $0 })
        default:
            return pastBrews.filter({ pastBrew in
                //
                // Return this past brew if the selected filter is in the filters list of this given brew equipment
                return (brews.brewEquipment.first(where: { $0.name == pastBrew.equipment })?.filters.contains(menuFilter.rawValue)) ?? false
            })
        }
    }
    
    var body: some View {
            VStack(spacing: 0) {
                toolbar
                if(pastBrewsToShow.isEmpty) {
                    emptyBrewList
                }
                else {
                    VStack {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(pastBrewsToShow) { brew in
                                    listDateHeader(brew.date)
                                    HStack(alignment: .center) {
                                        if(editing) {
                                            deleteButton(brew)
                                        }
                                        logCard(brew)
                                            .padding()
                                    }
                                    .transition(.slide)
                                    if (brew != pastBrewsToShow.last) {
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
            ForEach(BrewEquipmentList.MenuFilter.allCases, id: \.self) { menuCase in
                menuButton(text: menuCase == BrewEquipmentList.MenuFilter.showAll ? "Show All" : menuCase.rawValue, filter: menuCase)
            }        } ) {
            RoundedButton(buttonText: menuFilter == BrewEquipmentList.MenuFilter.showAll ? "Show All" : menuFilter.rawValue, buttonImage: "line.horizontal.3.circle", isSelected: true, action: {})
        }
    }
    
    func menuButton(text: String, filter: BrewEquipmentList.MenuFilter) -> some View {
        RoundedButton(buttonText: text, isSelected: (menuFilter == filter), action: { menuFilter = filter })
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
        let beanString = brew.bean!.roaster! + " " + brew.bean!.name!
        let grindString = brew.grind?.capitalizingFirstLetter() ?? "Grind"
        let coffeeAmountString = (String(brew.coffeeAmount) + brew.coffeeUnitString!)
        let waterAmountString = (String(brew.waterAmount) + brew.waterVolumeUnitString!)
        let waterTempString = (String(brew.waterTemp) + (brew.formattedTemperatureUnitString))
        let brewTimeString = String(format: "%2d:%02d", brew.timeMinutes(), brew.timeSeconds())
        let brewRatingString = String(brew.rating)
        
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
                    logCardRow("Beans:", beanString, showDivider: true)
                    logCardRow("Grind Size:", grindString, showDivider: true)
                    logCardRow("Coffee Amount:", coffeeAmountString, showDivider: true)
                    logCardRow("Water Amount:", waterAmountString, showDivider: true)
                    logCardRow("Water Temperature:", waterTempString, showDivider: true)
                    logCardRow("Brew Time:", brewTimeString, showDivider: true)
                    logCardRow("Rating:", brewRatingString, showDivider: false)
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
    static let brewList = BrewEquipmentList([BrewEquipment(id: 0, name: "Aero", type: "good", notes: "good", estTime: 5, filters: ["Immersion"])])
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
