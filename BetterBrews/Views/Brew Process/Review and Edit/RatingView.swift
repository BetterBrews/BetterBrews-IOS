//
//  RatingView.swift
//  BetterBrews
//
//  Created by Colby Haskell on 9/3/21.
//
//  TODO:
//  Test length limits on text in log review
//  Add Timer Option

import SwiftUI

struct RatingView: View {
    //MARK: - State
    @Binding var showBrewStack: Bool
    @ObservedObject var newBrew: NewBrew
    @State private var editingTime: Bool = true
    
    //MARK: - Body
    var body: some View {
        ZStack {
            Color("lightTan")
                .ignoresSafeArea()
            VStack(spacing: 0) {
                timeDisplay
                Divider()
                if(editingTime) {
                    timePicker
                        .transition(.opacity)
                        .animation(.spring(), value: editingTime)
                }
                VStack {
                    ratingPicker
                    logEntryReview(newBrew)
                }
                .background(AppStyle.backgroundColor)
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("Review")
                .toolbar(content: {
                    Button(action: finish) {
                        Text("Finish").foregroundColor(AppStyle.bodyTextColor)
                    }
                })
            }
        }
    }
    //MARK: - Time Display
    var timeDisplay: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("BREW TIME:")
                    .font(.caption)
                    .bold()
                    .foregroundColor(.black)
                Spacer()
                if(!editingTime) {
                    Button(editingTime ? "Done" : "Edit") {
                        withAnimation {
                            editingTime.toggle()
                        }
                    }
                    .foregroundColor(Color("lightBrown"))
                }
            }
            HStack {
                Spacer()
                Text(String(format: "%2d:%02d", newBrew.brewMinutes, newBrew.brewSeconds))
                    .bold()
                    .font(.largeTitle)
                    .foregroundColor(Color("black"))
                Spacer()
            }
            .padding()
        }
        .padding()
        .background(Color("tan"))
    }
    
    //MARK: - Timer Picker
    var timePicker: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Spacer()
                Button("Done") {
                    withAnimation {
                        editingTime.toggle()
                    }
                }
                    .foregroundColor(Color("lightBrown"))
            }
            .padding([.top, .horizontal])
            HStack(spacing: 0) {
                Picker(selection: $newBrew.brewMinutes, label: Text("minutes"), content: {
                    ForEach(0..<30) { min in
                        Text(String(min) + " min")
                    }
                })
                .pickerStyle(WheelPickerStyle())
                .frame(width: UIScreen.main.bounds.width/2)
                .clipped()
                Picker(selection: $newBrew.brewSeconds, label: Text("seconds"), content: {
                    ForEach(0..<60) { min in
                        Text(String(min) + " sec")
                    }
                })
                .pickerStyle(WheelPickerStyle())
                .frame(width: UIScreen.main.bounds.width/2)
                .clipped()
            }
            .transition(.slide)
        }
        .background(Color("brown"))
    }
    
    //MARK: - Log Entry Review Section
    struct logEntryReview: View {
        @ObservedObject var newBrew: NewBrew
        
        //Compute strings to display
        private var coffeeAmountString: String {
            newBrew.brew.coffeeAmountString + newBrew.brew.coffeeUnit.rawValue
        }
        private var waterAmountString: String {
            String(newBrew.brew.waterAmount!) + newBrew.brew.waterVolumeUnit.rawValue
        }
        private var waterTemperatureString: String {
            newBrew.brew.temperatureString + newBrew.brew.temperatureUnitString
        }
        private var beanNameString: String {
            //Test and limit text length if necessary
            newBrew.brew.bean!.roaster! + " " + newBrew.brew.bean!.name!
        }
        
        //State for editing views
        @State private var editEquipment = false
        @State private var editBeans = false
        @State private var editGrind = false
        @State private var editWater = false
        
        init(_ newBrew: NewBrew) {
            self.newBrew = newBrew
        }
        
        var body: some View {
            VStack(alignment: .leading) {
                logEntrySectionHeader
                Spacer()
                logEntryRow(label: "Brewed with", value: newBrew.brew.equipmentName)
                    .onTapGesture {
                        editEquipment.toggle()
                    }
                    .sheet(isPresented: $editEquipment) {
                        EditEquipmentView(newBrew: newBrew)
                    }
                logEntryRow(label: "Beans Used", value: beanNameString)
                    .onTapGesture {
                        editBeans.toggle()
                    }
                    .sheet(isPresented: $editBeans) {
                        BeanSelectionView(showBrewStack: .constant(true), newBrew: newBrew, reviewMode: true)
                    }
                logEntryRow(label: "Grind Size", value: newBrew.brew.grindSizeString!)
                    .onTapGesture {
                        editGrind.toggle()
                    }
                    .sheet(isPresented: $editGrind) {
                        GrindSelectionView(showBrewStack: .constant(true), newBrew: newBrew, reviewMode: true)
                    }
                logEntryRow(label: "Coffee Amount", value: coffeeAmountString)
                    .onTapGesture {
                        editGrind.toggle()
                    }
                logEntryRow(label: "Water Amount", value: waterAmountString)
                    .onTapGesture {
                        editWater.toggle()
                    }
                    .sheet(isPresented: $editWater) {
                        WaterInfoView(showBrewStack: .constant(true), newBrew: newBrew, reviewMode: true)
                    }
                logEntryRow(label: "Water Temperature", value: waterTemperatureString)
                    .onTapGesture {
                        editWater.toggle()
                    }
                Spacer()
            }
            .foregroundColor(Color("black"))
            .padding(.horizontal)
            .background(Color("lightTan"))
        }
        var logEntrySectionHeader: some View {
            HStack {
                Text("Log Entry:")
                    .bold()
                    .font(.title)
                Spacer()
            }
        }
        
        func logEntryRow(label: String, value: String) -> some View {
                VStack {
                    Spacer(minLength: 0)
                    HStack {
                        Text(label + ":")
                        Spacer()
                        HStack {
                            Text(value)
                            Image(systemName: "chevron.right")
                        }
                        .foregroundColor(Color("lightBrown"))
                    }
                    .font(.headline)
                    Spacer(minLength: 0)
                }
        }
    }
    
    
    var ratingPicker: some View {
        VStack {
            HStack {
                Text("RATE YOUR CUP:")
                    .font(.caption)
                    .bold()
                    .foregroundColor(.black)
                Spacer()
            }
            Picker(selection: $newBrew.brew.rating, label: Text("Cup Rating"), content: {
                ForEach(1..<11) { score in
                    Text(String(score)).tag(Int(score))
                }
            })
            .padding(viewConstants.pickerPadding)
            .pickerStyle(SegmentedPickerStyle())
            .background(RoundedRectangle(cornerRadius: viewConstants.rowCornerRadius).foregroundColor(AppStyle.listRowBackgroundColor))
            .padding(.vertical)
            Divider()
                .background(Color(.black))
        }
        .padding()
    }
    
    var tasteNotesField: some View {
        VStack {
            HStack {
                Text("TASTE NOTES:")
                    .font(.caption)
                    .bold()
                Spacer()
            }
            expandingTextField
        }
        .padding([.horizontal, .bottom])
    }
    
    var expandingTextField: some View {
        VStack {
            TextEditor(text: $newBrew.brew.notes)
                //.colorScheme(.dark)
                .foregroundColor(Color("gold"))
            Spacer()
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: viewConstants.rowCornerRadius).foregroundColor(Color("brown")))
    }
    
    func finish() {
        withAnimation {
            newBrew.save()
            showBrewStack.toggle()
        }
    }
    
    
    struct viewConstants {
        static let pickerPadding: CGFloat = 2
        static let rowCornerRadius: CGFloat = 10
    }
    
}


struct RatingView_Previews: PreviewProvider {
    static let newBrew = NewBrew(method: BrewEquipment(id: 0, name: "Aeropress", type: "Immersion", notes: "Good", estTime: 6, filters: ["Immersion"]), beanName: "44 North", grind: "Coarse", brewTime: 5.30, waterTemp: 5, waterAmount: 5.5, coffeeAmount: 5.5)
    
    static var previews: some View {
        NavigationView {
            RatingView(showBrewStack: .constant(true), newBrew: newBrew)
        }
        .preferredColorScheme(.dark)
        .previewDevice("iPhone 12 Pro Max")
    }
}
