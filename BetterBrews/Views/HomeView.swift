//
//  HomeView.swift
//  BetterBrews
//
//  Created by Colby Haskell on 8/11/21.
//

import SwiftUI
import CoreData

struct HomeView: View {
<<<<<<< HEAD
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @EnvironmentObject var brewEquipment: EquipmentList
    
    @FetchRequest private var pastBrews: FetchedResults<PastBrew>
    
    init() {
        let request: NSFetchRequest<PastBrew> = PastBrew.fetchRequest()
        request.fetchLimit = 5
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

        _pastBrews = FetchRequest(fetchRequest: request)
    }
    
    
=======
    @EnvironmentObject var brewEquipment: EquipmentList
    
>>>>>>> 13700549c246f75eeacfe50be3be30be84e49bfd
    //MARK: State
    @GestureState private var dragAmount = CGFloat.zero
    @State private var displayedIndex = 0
    @State private var menuFilter = MenuFilter.showAll
    @State private var menuExpanded = false
    @State private var showAddBrewView = false
    @State private var showBrewProcess = false
    @State private var chosenBrew: BrewEquipment = BrewEquipment(id: 0, name: "Brew", type: "Immersion", notes: "Good", estTime: 6)
    
<<<<<<< HEAD
    let cardWidth: CGFloat = UIScreen.main.bounds.width - (viewConstants.hiddenCardWidth*2) - (viewConstants.cardSpacing*2)
    
=======
>>>>>>> 13700549c246f75eeacfe50be3be30be84e49bfd
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
<<<<<<< HEAD
                    Spacer()
                    menuBar
                        .border(Color.blue)
                    Spacer()
                    brewCardCarousel
                    .border(Color.red)
                    Spacer()
                    recentlyUsed
                        .border(Color.green)
=======
                    BrewCarouselSection
                    VStack {
                        recentlyUsed
                    }
>>>>>>> 13700549c246f75eeacfe50be3be30be84e49bfd
                }
            }
            .toolbar { ToolbarItem(placement: .principal) { toolbarTitle } }
            .navigationBarItems(leading: logIcon, trailing: settingsIcon)
        }
        .preferredColorScheme(.light)
        
    }
    
<<<<<<< HEAD
=======
    var BrewCarouselSection: some View {
            VStack(alignment: .leading, spacing: 0) {
                menuBar
                GeometryReader { geo in
                    brewCardCarousel
                        .padding(.bottom)
                }
            }
    }
    
>>>>>>> 13700549c246f75eeacfe50be3be30be84e49bfd
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
<<<<<<< HEAD
                    .foregroundColor(.white)
                    .font(.subheadline)
                    .padding(5)
                    .background(Circle().foregroundColor(Color("gold")))
=======
                    .foregroundColor(Color("gold"))
                    .shadow(radius: 10)
>>>>>>> 13700549c246f75eeacfe50be3be30be84e49bfd
            }
            .sheet(isPresented: $showAddBrewView, content: {
                AddBrewView()
            })
        }
<<<<<<< HEAD
        .padding(.horizontal)
=======
        .padding([.top, .horizontal])
>>>>>>> 13700549c246f75eeacfe50be3be30be84e49bfd
    }

    func menuButton(text: String, filter: MenuFilter) -> some View {
        RoundedButton(buttonText: text, isSelected: (menuFilter == filter), action: { menuFilter = filter })
    }
    
    func setFilter(_ filter: MenuFilter) {
        menuFilter = filter
        displayedIndex = 0
    }
    
    //MARK: - Card Carousel
<<<<<<< HEAD
var brewCardCarousel: some View {
=======
    var brewCardCarousel: some View {
>>>>>>> 13700549c246f75eeacfe50be3be30be84e49bfd
        //Dynamically compute card width based on screen size
        let cardWidth: CGFloat = UIScreen.main.bounds.width - (viewConstants.hiddenCardWidth*2) - (viewConstants.cardSpacing*2)
        
        let xOffset = viewConstants.cardSpacing + viewConstants.hiddenCardWidth
        let totalMovement = cardWidth + viewConstants.cardSpacing
        
        let currentOffset: CGFloat = xOffset - (totalMovement * CGFloat(displayedIndex))
        let nextOffset: CGFloat = xOffset - (totalMovement * CGFloat(displayedIndex) + 1)
        
        var carousel: some View {
<<<<<<< HEAD
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
=======
            HStack {
                NavigationLink(destination: BeanSelectionView(showSelf: $showBrewProcess, newBrew: NewBrew(chosenBrew)), isActive: $showBrewProcess) {
                        EmptyView()
                }
                .isDetailLink(false)
                ForEach(brewsToShow) { brew in
                    GeometryReader { cardViewGeometry in
                        methodCard(brew: brew, proxy: cardViewGeometry)
                            .gesture(listSwipe)
                            .rotation3DEffect(rotationAngle(cardViewGeometry), axis: (x:0, y: 10.0, z: 0))
                            .transition(.slide)
                            .animation(.spring(), value: displayedIndex)
                            
                    }
                    .frame(width: cardWidth)
                    .buttonStyle(FlatLinkStyle())
                    .offset(x: calcOffset)
                    .onTapGesture {
                        chosenBrew = brew
                        showBrewProcess.toggle()
                    }
>>>>>>> 13700549c246f75eeacfe50be3be30be84e49bfd
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
    
<<<<<<< HEAD
    func testCard(_ brew: BrewEquipment) -> some View {
        VStack {
            GeometryReader { cardGeo in
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text(brew.name)
                            .font(.title)
                            .bold()
                            .foregroundColor(Color("gold"))
                        Spacer()
                        Text(String(Int(cardGeo.size.height)))
                            .foregroundColor(.white)
                    }
                    VStack(alignment: .leading, spacing: 0) {
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
=======
    func methodCard(brew: BrewEquipment, proxy: GeometryProxy) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: viewConstants.methodCardCornerRadius)
                            .foregroundColor(AppStyle.titleColor)
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(brew.name)
                        .font(.title2)
                        .bold()
                        .foregroundColor(Color("gold"))
                    Spacer()
                }
                HStack {
                    Text("Brew Type:")
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
                Text("Notes:")
                    .font(.headline)
                    .foregroundColor(Color("lightTan"))
                Text("Aeropress makes a smooth brew that constisisij of likely to make good coffee")
                    //.allowsTightening(true)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.subheadline)
                    .foregroundColor(Color(.white))
                Spacer()
                Image(systemName: brew.isFavorite ? "star.fill" : "star")
                    .foregroundColor(Color("gold"))
                    .font(.headline)
                    .onTapGesture {
                        brewEquipment.addAsFavorite(brew.id)
                    }
            }
            .allowsTightening(true)
            .padding(viewConstants.cardPadding)
        }
        .padding()
        
>>>>>>> 13700549c246f75eeacfe50be3be30be84e49bfd
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
<<<<<<< HEAD
            if(pastBrews.isEmpty) {
                Spacer()
            }
            else {
                VStack(spacing: viewConstants.recentlyUsedSpacing) {
                    ScrollView {
                        ForEach(pastBrews) { brew in
                            recentCard(brew)
=======
            if(false) {
                Spacer()
            }
            else {
                ScrollView {
                    VStack(spacing: viewConstants.recentlyUsedSpacing) {
                        ForEach(0..<2) { _ in
                            recentCard
>>>>>>> 13700549c246f75eeacfe50be3be30be84e49bfd
                        }
                    }
                }
            }
        }
        .padding([.top, .horizontal])
        .background(Color("lightTan"))
<<<<<<< HEAD
    }
    
    func recentCard(_ brew: PastBrew) -> some View {
=======
        .frame(height: UIScreen.main.bounds.height/3.4)
    }
    
    //
    //
    //TODO:
    var recentCard: some View {
>>>>>>> 13700549c246f75eeacfe50be3be30be84e49bfd
        ZStack {
            RoundedRectangle(cornerRadius: 25.0)
                .foregroundColor(Color("black"))
            HStack {
<<<<<<< HEAD
                VStack(alignment: .leading, spacing: viewConstants.cardListSpacing) {
                    HStack {
                        Text(brew.equipment!)
=======
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text("French Press")
>>>>>>> 13700549c246f75eeacfe50be3be30be84e49bfd
                            .font(.headline)
                            .foregroundColor(AppStyle.accentColor)
                        Spacer()
                    }
                    HStack {
                        Text("Last Used:")
                            .font(.caption)
                            .foregroundColor(.white)
<<<<<<< HEAD
                        //Text(brew.date!.stringFromDate())
=======
                        Text("June 7, 2021")
>>>>>>> 13700549c246f75eeacfe50be3be30be84e49bfd
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                    //.padding(.vertical, 5)
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
        static let cardListSpacing: CGFloat = 3
<<<<<<< HEAD
        static let cardPadding: CGFloat = 20
        static let cardWidthScale: CGFloat = 1/2.5
        static let cardHeightScale: CGFloat = 1/2.7
        static let minDrag: CGFloat = 15
        static let cardSpacing: CGFloat = 2
        static let cardMinSwipe: CGFloat = 60
        static let hiddenCardWidth: CGFloat = 50
        static let methodCardCornerRadius: CGFloat  = 40
        static let cardWidth: CGFloat = UIScreen.main.bounds.width - (viewConstants.hiddenCardWidth*2) - (viewConstants.cardSpacing*2)
=======
        static let cardPadding: CGFloat = 25
        static let cardWidthScale: CGFloat = 1/2.5
        static let cardHeightScale: CGFloat = 1/2.7
        static let minDrag: CGFloat = 15
        static let cardSpacing: CGFloat = 5
        static let cardMinSwipe: CGFloat = 60
        static let hiddenCardWidth: CGFloat = 45
        static let methodCardCornerRadius: CGFloat  = 40
>>>>>>> 13700549c246f75eeacfe50be3be30be84e49bfd
        
        /* Menu Bar */
        static let menuBarPadding: CGFloat = 10
        static let menuBarSpacing: CGFloat = 20
        static let menuButtonCornerRadius: CGFloat = 25
        
        /* Recently Used */
        static let recentlyUsedSpacing: CGFloat = 15
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static let equipment = EquipmentList([BrewEquipment(id: 0, name: "Aeropress", type: "Immersion", notes: "good", estTime: 5, isFavorite: true), BrewEquipment(id: 1, name: "French Press", type: "Immersion", notes: "good", estTime: 5, isFavorite: true), BrewEquipment(id: 2, name: "Moka Pot", type: "Immersion", notes: "good", estTime: 5, isFavorite: true)])

    static var previews: some View {
        HomeView()
<<<<<<< HEAD
            .previewDevice("iPhone 8")
=======
            .previewDevice("iPhone 12 Pro")
>>>>>>> 13700549c246f75eeacfe50be3be30be84e49bfd
            .preferredColorScheme(.light)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(equipment)
    }
}
