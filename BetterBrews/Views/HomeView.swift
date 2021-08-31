//
//  HomeView.swift
//  BetterBrews
//
//  Created by Colby Haskell on 8/11/21.
//

import SwiftUI
import CoreData

struct HomeView: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @EnvironmentObject var brewEquipment: EquipmentList
    
    @FetchRequest private var pastBrews: FetchedResults<PastBrew>
    
    init() {
        let request: NSFetchRequest<PastBrew> = PastBrew.fetchRequest()
        request.fetchLimit = 5
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

        _pastBrews = FetchRequest(fetchRequest: request)
    }
    
    
    //MARK: State
    @GestureState private var dragAmount = CGFloat.zero
    @State private var displayedIndex = 0
    @State private var menuFilter = MenuFilter.showAll
    @State private var menuExpanded = false
    @State private var showAddBrewView = false
    @State private var showBrewProcess = false
    @State private var chosenBrew: BrewEquipment = BrewEquipment(id: 0, name: "Brew", type: "Immersion", notes: "Good", estTime: 6)
    
    let cardWidth: CGFloat = UIScreen.main.bounds.width - (viewConstants.hiddenCardWidth*2) - (viewConstants.cardSpacing*2)
    
    private var brewsToShow: [BrewEquipment] {
        switch(menuFilter) {
        case .favorites:
            return brewEquipment.favorites
        default:
            return brewEquipment.brewEquipment
        }
    }
    
    enum MenuFilter {
        case showAll
        case favorites
        case espresso
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color("lightTan")
                    .ignoresSafeArea()
                Color("tan")
                VStack(alignment: .leading, spacing: 0) {
                    Spacer()
                    menuBar
                        .border(Color.blue)
                    Spacer()
                    brewCardCarousel
                    .border(Color.red)
                    Spacer()
                    recentlyUsed
                        .border(Color.green)
                }
            }
            .toolbar { ToolbarItem(placement: .principal) { toolbarTitle } }
            .navigationBarItems(leading: logIcon, trailing: settingsIcon)
        }
        .preferredColorScheme(.light)
        
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
                menuButton(text: "Show All", filter: MenuFilter.showAll)
                menuButton(text: "Favorites", filter: MenuFilter.favorites)
                menuButton(text: "Espresso", filter: MenuFilter.espresso)
            }, label: {
                RoundedButton(buttonText: "Filter", buttonImage: "line.horizontal.3.circle", isSelected: true, action: {})
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
            ScrollView(.horizontal) {
                HStack {
                    NavigationLink(destination: BeanSelectionView(showSelf: $showBrewProcess, newBrew: NewBrew(chosenBrew)), isActive: $showBrewProcess) {
                            EmptyView()
                    }
                    .isDetailLink(false)
                    ForEach(brewsToShow) { brew in
                        testCard(brew)
                            .frame(width: viewConstants.cardWidth)
                            .buttonStyle(FlatLinkStyle())
                            .gesture(listSwipe)
                            .transition(.slide)
                            .animation(.spring(), value: displayedIndex)
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
    
    func testCard(_ brew: BrewEquipment) -> some View {
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
                            Text("Good \nGood \nGood")
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
                .rotation3DEffect(rotationAngle(cardGeo), axis: (x:0, y: 10.0, z: 0))
                .border(Color.white)
            }
            
        }
        .padding(viewConstants.cardPadding)
        .background(RoundedRectangle(cornerRadius: viewConstants.methodCardCornerRadius)
                        .foregroundColor(AppStyle.titleColor))
    }
    
    private func cardAverageRatingString(_ brewName: String) -> String {
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
            return (pastbrew?.date)!
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
                .bold()
                .padding(.bottom)
            if(pastBrews.isEmpty) {
                Spacer()
            }
            else {
                VStack() {
                    ScrollView {
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
    }
    
    //MARK: - Constants, Colors
    private struct viewConstants {
        /* Toolbar */
        static let logIconName = "chart.bar.doc.horizontal.fill"
        static let settingsIconName = "gear"
        
        /* Card Carousel */
        static let cardPadding: CGFloat = 20
        static let cardWidthScale: CGFloat = 1/2.5
        static let cardHeightScale: CGFloat = 1/2.7
        static let minDrag: CGFloat = 15
        static let cardSpacing: CGFloat = 2
        static let cardMinSwipe: CGFloat = 60
        static let hiddenCardWidth: CGFloat = 50
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
    
    static let equipment = EquipmentList([BrewEquipment(id: 0, name: "Aeropress", type: "Immersion", notes: "good", estTime: 5, isFavorite: true), BrewEquipment(id: 1, name: "French Press", type: "Immersion", notes: "good", estTime: 5, isFavorite: true), BrewEquipment(id: 2, name: "Moka Pot", type: "Immersion", notes: "good", estTime: 5, isFavorite: true)])

    static var previews: some View {
        HomeView()
            .previewDevice("iPhone 12 Pro Max")
            .preferredColorScheme(.light)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(equipment)
    }
}
