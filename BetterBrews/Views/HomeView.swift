//
//  HomeView.swift
//  BetterBrews
//
//  Created by Colby Haskell on 8/11/21.
//

import SwiftUI
import CoreData

struct HomeView: View {
    //MARK: - State
    @EnvironmentObject var globalSettings: GlobalSettings
    @EnvironmentObject var brewEquipment: BrewEquipmentList
    
    @GestureState private var dragAmount = CGFloat.zero
    @State private var displayedIndex = 0
    @State private var menuFilter = MenuFilter.showAll
    @State private var menuExpanded = false
    @State private var showAddBrewView = false
    @State private var showBrewProcess = false
    @State private var chosenBrew: BrewEquipment = BrewEquipment(id: 0, name: "Brew", type: "Immersion", notes: "Good", estTime: 6, filters: ["Immersion"])
    
    @FetchRequest private var pastBrews: FetchedResults<PastBrew>
    
    let cardWidth: CGFloat = UIScreen.main.bounds.width - (viewConstants.hiddenCardWidth*2) - (viewConstants.cardSpacing*2)
    
    private var brewsToShow: [BrewEquipment] {
        switch(menuFilter) {
        case .Favorites:
            return brewEquipment.favorites
        case .showAll:
            return brewEquipment.brewEquipment
        default:
            return brewEquipment.brewEquipment.filter({ $0.filters.contains(menuFilter.rawValue)})
        }
    }
    
    enum MenuFilter: String, CaseIterable {
        case showAll
        case Favorites
        case Espresso
        case Immersion
        case Pourover
        case Drip
        case Custom
    }
    //MARK: - Init
    init() {
        let request: NSFetchRequest<PastBrew> = PastBrew.fetchRequest()
        request.fetchLimit = 5
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

        _pastBrews = FetchRequest(fetchRequest: request)
    }
    
    //MARK: - Body
    var body: some View {
        NavigationView {
            ZStack {
                Color("lightTan")
                    .ignoresSafeArea()
                Color("tan")
                VStack(alignment: .leading, spacing: viewConstants.primarySpacing) {
                    Spacer()
                    menuBar
                    Spacer()
                    brewCardCarousel
                    Spacer()
                    recentlyUsed
                }
            }
            .toolbar { ToolbarItem(placement: .principal) { toolbarTitle } }
            .navigationBarItems(leading: logIcon, trailing: settingsIcon)
        }
    }
    
    //MARK: - Toolbar
    var toolbarTitle: some View {
        HStack(spacing: 0) {
            Text("Better")
                .font(.title)
                .bold()
                .foregroundColor(AppStyle.titleColor)
            Text("Brew")
                .font(.title)
                .bold()
                .foregroundColor(AppStyle.accentColor)
        }
        
    }
    var logIcon: some View {
        NavigationLink(destination: LogView()) {
            Image(systemName: viewConstants.logIconName)
                .font(.title)
                .foregroundColor(Color("black"))
        }
        .padding(.vertical)
    }
    var settingsIcon: some View {
        NavigationLink(destination: SettingsView()) {
            Image(systemName: viewConstants.settingsIconName)
                .foregroundColor(Color("black"))
                .font(.title)
        }
    }
    
    //MARK: - Buttons
    
    var menuBar: some View {
        HStack {
            Menu(content: {
                ForEach(MenuFilter.allCases, id: \.self) { menuCase in
                        menuButton(text: menuCase == MenuFilter.showAll ? "Show All" : menuCase.rawValue, filter: menuCase)
                }
            }, label: {
                RoundedButton(buttonText: menuFilter == MenuFilter.showAll ? "Show All" : menuFilter.rawValue, buttonImage: "line.horizontal.3.circle", isSelected: true, action: {})
            })
            Spacer()
            Button(action: { showAddBrewView.toggle() }) {
                Image(systemName: "plus")
                    .foregroundColor(.white)
                    .font(.subheadline)
                    .padding(5)
                    .background(Circle().foregroundColor(Color("gold")))
            }
            .sheet(isPresented: $showAddBrewView, content: {
                AddBrewView()
                    .environment(\.colorScheme, .dark)
            })
        }
        .padding(.horizontal)
    }

    func menuButton(text: String, filter: MenuFilter) -> some View {
        RoundedButton(buttonText: text, isSelected: (menuFilter == filter), action: { menuFilter = filter })
    }
    
    func setFilter(_ filter: MenuFilter) {
        menuFilter = filter
        displayedIndex = 0
    }
    
    //MARK: - Card Carousel
    var brewCardCarousel: some View {
        //Dynamically compute card width based on screen size
        let cardWidth: CGFloat = UIScreen.main.bounds.width - (viewConstants.hiddenCardWidth*2) - (viewConstants.cardSpacing*2)
        
        let xOffset = viewConstants.cardSpacing + viewConstants.hiddenCardWidth
        let totalMovement = cardWidth + viewConstants.cardSpacing
        
        let currentOffset: CGFloat = xOffset - (totalMovement * CGFloat(displayedIndex))
        let nextOffset: CGFloat = xOffset - (totalMovement * CGFloat(displayedIndex) + 1)
        
        var carousel: some View {
            GeometryReader { geo in
                HStack {
                    NavigationLink(destination: BeanSelectionView(showBrewStack: $showBrewProcess, newBrew: NewBrew(chosenBrew)).environmentObject(globalSettings), isActive: $showBrewProcess) {
                            EmptyView()
                    }
                    .isDetailLink(false)
                }
                HStack(spacing: viewConstants.cardSpacing) {
                    ForEach(brewsToShow) { brew in
                        brewDisplayCard(brew)
                            .frame(width: viewConstants.cardWidth)
                            .buttonStyle(FlatLinkStyle())
                            .gesture(listSwipe)
                            .transition(.slide)
                            .animation(.spring(), value: displayedIndex)
                            .onTapGesture {
                                chosenBrew = brew
                                showBrewProcess.toggle()
                            }
                    }
                    .offset(x: calcOffset)
                }
            }
        }
        
        //Controls offset for drag + snap
        var calcOffset: CGFloat {
            get {
                if(currentOffset != nextOffset) {
                    return currentOffset + dragAmount
                }
                else {
                    return currentOffset
                }
            }
        }
        
        return carousel
    }
    
    func brewDisplayCard(_ brew: BrewEquipment) -> some View {
        VStack {
            GeometryReader { cardGeo in
                VStack(alignment: .leading, spacing: 0) {
                    VStack(alignment: .leading, spacing: cardGeo.size.height/viewConstants.spacingHeightFactor) {
                        HStack {
                            Text(brew.name)
                                .font(.title)
                                .bold()
                                .foregroundColor(Color("gold"))
                            Spacer()
                        }
                        HStack {
                            Text("Type:")
                                .foregroundColor(Color("lightTan"))
                                .font(.headline)
                            Text(brew.type)
                                .foregroundColor(Color(.white))
                                .font(.subheadline)
                        }
                        HStack {
                            Text("Est. Time:")
                                .font(.headline)
                                .foregroundColor(Color("lightTan"))
                            Text(String(format: "%1d:00", brew.estTime))
                                .foregroundColor(Color(.white))
                                .font(.subheadline)
                        }
                        VStack(alignment: .leading) {
                            Text("Notes:")
                                .font(.headline)
                                .foregroundColor(Color("lightTan"))
                            Text(brew.notes)
                                .lineLimit(3)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                                .font(.subheadline)
                                .padding(.leading)
                                .foregroundColor(Color(.white))
                        }
                        if(cardGeo.size.height >= 200) {
                            HStack {
                                Text("Average Rating:")
                                    .foregroundColor(Color("lightTan"))
                                    .font(.headline)
                                Text(cardAverageRatingString(brew.name))
                                    .foregroundColor(.white)
                                
                            }
                        }
                    }
                    Spacer(minLength: 0)
                    Image(systemName: brew.isFavorite ? "star.fill" : "star")
                        .foregroundColor(Color("gold"))
                        .font(.headline)
                        .onTapGesture {
                            addFavorite(brew)
                        }
                }
                .padding(viewConstants.cardPadding)
                .background(RoundedRectangle(cornerRadius: viewConstants.methodCardCornerRadius)
                                .foregroundColor(AppStyle.titleColor))
                .rotation3DEffect(rotationAngle(cardGeo), axis: (x:0, y: 10.0, z: 0))
            }
            
            
        }
    }
    
    private func cardAverageRatingString(_ brewName: String) -> String {
        //let brews = pastBrews.all
        let date = dateLastUsed(brewName)
        if(date == Date(timeIntervalSince1970: 0)) {
            return "N/A"
        }
        else {
            return date.stringFromDate()
        }
    }
    
    private func dateLastUsed(_ brewName: String) -> Date{
        let pastbrew = pastBrews.first(where: {
            $0.equipment == brewName
        })
        if(pastbrew != nil) {
            return Date(timeIntervalSince1970: 0)
        }
        else {
            return Date(timeIntervalSince1970: 0)
        }
    }
    
    private func addFavorite(_ brew: BrewEquipment) {
        brewEquipment.addAsFavorite(brew.id)
    }
    
    private func startBrew(_ brew: BrewEquipment) {
        chosenBrew = brew
        showBrewProcess.toggle()
    }
    
    //Style to remove link press animation on card
    struct FlatLinkStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
        }
    }
    
    var listSwipe: some Gesture {
        DragGesture(minimumDistance: 5, coordinateSpace: .global)
            .updating($dragAmount) { value, state, transaction in
                state = value.translation.width
            }
            .onEnded { value in
                let horizontalAmount = value.translation.width as CGFloat
                let verticalAmount = value.translation.height as CGFloat
                        
                //Verify horizontal swipe
                if ((abs(horizontalAmount) > viewConstants.cardMinSwipe) && (abs(horizontalAmount) > abs(verticalAmount))) {
                    //Left Swipe
                    if(horizontalAmount < 0) {
                        if(displayedIndex < brewsToShow.count - 1) {
                            displayedIndex += 1
                        }
                    }
                    //Right Swipe
                    else {
                        if(displayedIndex > 0) {
                            displayedIndex -= 1
                        }
                    }
                }
            }
    }
    
    func rotationAngle(_ geometry: GeometryProxy) -> Angle {
        Angle(degrees: -((Double(geometry.frame(in: .global).minX) - Double(viewConstants.cardSpacing + viewConstants.hiddenCardWidth))/18))
    }
    
    //MARK: - Recently Used
    var recentlyUsed: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Recently Used:")
                .font(.title2)
                .foregroundColor(.black)
                .bold()
                .padding(.bottom)
            if(pastBrews.isEmpty) {
                Spacer()
                HStack {
                    Spacer()
                    Text("No Brews Yet...")
                        .font(.headline)
                        .bold()
                        .foregroundColor(.black)
                    Spacer()
                }
                Spacer()
            }
            else {
                VStack() {
                    ScrollView(.vertical) {
                        VStack(spacing: viewConstants.recentlyUsedSpacing) {
                            ForEach(pastBrews) { brew in
                                recentCard(brew)
                            }
                        }
                    }
                }
            }
        }
        .padding([.top, .horizontal])
        .background(Color("lightTan"))
    }
    
    func recentCard(_ brew: PastBrew) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25.0)
                .foregroundColor(Color("black"))
            HStack {
                VStack(alignment: .leading, spacing: viewConstants.recentCardSpacing) {
                    HStack {
                        Text(brew.equipment!)
                            .font(.headline)
                            .foregroundColor(AppStyle.accentColor)
                        Spacer()
                    }
                    HStack {
                        Text("Last Used:")
                            .font(.caption)
                            .foregroundColor(.white)
                        Text(brew.date!.stringFromDate())
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                }
                Image(systemName: "chevron.right")
                    .foregroundColor(AppStyle.accentColor)
                
            }
            .padding()
        }
        .onTapGesture {
            if let equipment = brewEquipment.brewEquipment.first(where: { $0.name == brew.equipment!}) {
                chosenBrew = equipment
                showBrewProcess.toggle()
            }
        }
    }
    
    //MARK: - Constants, Colors
    private struct viewConstants {
        static let primarySpacing: CGFloat = 5
        /* Toolbar */
        static let logIconName = "chart.bar.doc.horizontal.fill"
        static let settingsIconName = "gear"
        
        /* Card Carousel */
        static let cardPadding: CGFloat = 20
        static let cardWidthScale: CGFloat = 1/2.5
        static let cardHeightScale: CGFloat = 1/2.7
        static let minDrag: CGFloat = 15
        static let cardSpacing: CGFloat = 0
        static let cardMinSwipe: CGFloat = 60
        static let hiddenCardWidth: CGFloat = 65
        static let methodCardCornerRadius: CGFloat  = 40
        static let cardWidth: CGFloat = UIScreen.main.bounds.width - (viewConstants.hiddenCardWidth*2) - (viewConstants.cardSpacing*2)
        static let spacingHeightFactor: CGFloat = 45
        
        /* Menu Bar */
        static let menuBarPadding: CGFloat = 10
        static let menuBarSpacing: CGFloat = 20
        static let menuButtonCornerRadius: CGFloat = 25
        
        /* Recently Used */
        static let recentlyUsedSpacing: CGFloat = 20
        static let recentCardSpacing: CGFloat = 10
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static let equipment = BrewEquipmentList([BrewEquipment(id: 0, name: "Aeropress", type: "Immersion", notes: "good", estTime: 5, filters: ["Immersion"], isFavorite: true), BrewEquipment(id: 1, name: "French Press", type: "Immersion", notes: "good", estTime: 5, filters: ["Immersion"], isFavorite: true), BrewEquipment(id: 2, name: "Moka Pot", type: "Immersion", notes: "good", estTime: 5, filters: ["Espresso"], isFavorite: true)])

    static var previews: some View {
        HomeView()
            .previewDevice("iPhone 12 Pro Max")
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(equipment)
            .environmentObject(GlobalSettings())
    }
}
