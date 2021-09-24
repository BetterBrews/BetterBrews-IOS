//
//  RatingView.swift
//  BetterBrews
//
//  Created by Colby Haskell on 9/3/21.
//

import SwiftUI

struct RatingView: View {
    //MARK: - State
    @Binding var showSelf: Bool
    @ObservedObject var newBrew: NewBrew
    @State private var editingTime: Bool = true
    //@State private var tasteNotesString: String = ""
    
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
                inputForm
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle("Review")
                    .toolbar(content: {
                        Button("Finish") { finish() }
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
    
    //MARK: - Input Form
    var inputForm: some View {
        VStack {
            ratingPicker
            logEntrySection
        }
        .background(AppStyle.backgroundColor)
    }
    
    //MARK: - Log Entry Section
    var logEntrySection: some View {
        VStack(alignment: .leading) {
            logEntrySectionHeader
            Divider()
                .background(Color(.black))
            Spacer()
            logEntryRow(label: "Brewed with", value: newBrew.brew.brewEquipment)
            logEntryRow(label: "Beans Used", value: newBrew.brew.bean!.name!)
            logEntryRow(label: "Grind Size", value: newBrew.brew.grindSizeString!)
            logEntryRow(label: "Coffee Amount", value: (newBrew.brew.coffeeAmountString + newBrew.brew.coffeeUnit.rawValue))
            logEntryRow(label: "Water Amount", value: String(newBrew.brew.waterAmount!))
            logEntryRow(label: "Water Temperature", value:
                            newBrew.brew.temperatureString + newBrew.brew.temperatureUnitString)
            Spacer()
        }
        .foregroundColor(Color("black"))
        .padding([.top, .horizontal])
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
                Button(action: { }) {
                    Text(value)
                    Image(systemName: "chevron.right")
                }
                .foregroundColor(Color("lightBrown"))
            }
            .font(.headline)
            Spacer(minLength: 0)
        }
    }
    var ratingPicker: some View {
        VStack {
            HStack {
                Text("RATE YOUR CUP:")
                    .font(.caption)
                    .bold()
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
            .padding(.top)
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
            showSelf.toggle()
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
            RatingView(showSelf: .constant(true), newBrew: newBrew)
        }
        .previewDevice("iPhone 12 Pro Max")
    }
}
