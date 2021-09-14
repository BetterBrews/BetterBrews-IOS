//
//  BrewTimerView.swift
//  BetterBrews
//
//  Created by Colby Haskell on 8/11/21.
//

import SwiftUI

struct BrewTimerView: View {
    //@EnvironmentObject var settings: GlobalSettings
    @Binding var showSelf: Bool
    @State var showTimePicker: Bool = false
    @State var nextView: Bool = false
    @ObservedObject var newBrew: NewBrew
    @ObservedObject var timer = BrewTimer()
    
    private var brewTime: Double {
        Double(timer.minutesElapsed) + Double(timer.secondsElapsed)/100
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            timerSection
            logEntrySection
        }
        .background(Color("lightTan").ignoresSafeArea())
        .navigationBarTitle("Brew Timer")
        .navigationBarTitleDisplayMode(.inline)
    }
    var timerSection: some View {
        VStack {
            Spacer()
            timerView
            Spacer()
            if(timer.mode != .running) {
                startButton
            }
            else {
                pauseButton
            }
            finishButton
            Spacer()
        }
        .background(Color("tan"))
    }
    
    var logEntrySection: some View {
        var logEntrySectionHeader: some View {
            HStack {
                Text("Log Entry:")
                    .bold()
                    .font(.title)
                Spacer()
            }
        }
        
        return
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
                logEntryRow(label: "Water Temperature", value: (newBrew.brew.temperatureString + newBrew.brew.temperatureUnit.rawValue))
                Spacer()
            }
            .foregroundColor(Color("black"))
            .padding([.top, .horizontal])
            .background(Color("lightTan"))
    }
    
    func logEntryRow(label: String, value: String) -> some View {
        VStack {
            Spacer(minLength: 0)
            HStack {
                Text(label + ":")
                Spacer()
                Text(value)
            }
            .font(.headline)
            Spacer(minLength: 0)
        }
    }
    var pauseButton: some View {
        Button(action: pauseTimer) {
            HStack {
                Spacer()
                Text("Pause Timer")
                    .foregroundColor(Color("gold"))
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(Color("brown"))
            )
            .padding(.horizontal)
        }
    }
    var startButton: some View {
        Button(action: startTimer) {
            HStack {
                Spacer()
                Text("Start Timer")
                    .foregroundColor(Color("gold"))
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(Color("brown"))
            )
            .padding(.horizontal)
        }
    }
    
    //MARK: Skip Timer Button
    var finishButton: some View {
        HStack {
            Spacer()
            NavigationLink(
                destination: RatingView(showSelf: $showSelf, newBrew: newBrew), isActive: $nextView, label: {
                    EmptyView()
                })
            Button("Finish", action: next)
            Spacer()
            Image(systemName: "chevron.right")
            
        }
        .foregroundColor(Color("gold"))
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(AppStyle.listRowBackgroundColor)
        )
        .padding()
    }
    
    func startTimer() {
        timer.start()
    }
    
    func pauseTimer() {
        timer.pause()
    }
    
    func next() {
        timer.pause()
        newBrew.brew.brewTime = Double(brewTime)
        nextView.toggle()
    }
    
    var timerView: some View {
        HStack {
            Spacer()
            Text(String(format: "%2d:%02d:%1d", timer.minutes, timer.seconds, timer.deciseconds))
                .bold()
                .font(.largeTitle)
                .foregroundColor(Color("black"))
            Spacer()
        }
    }
    
    struct viewConstants {
        static let logFieldSpacing: CGFloat = 20
    }
}

struct BrewTimerView_Previews: PreviewProvider {
    static let newBrew = NewBrew(method: BrewEquipment(id: 0, name: "Aeropress", type: "Immersion", notes: "Good", estTime: 6, filters: ["Immersion"]), beanName: "44 North", grind: "Coarse", brewTime: 5.5, waterTemp: 5, waterAmount: 5.5, coffeeAmount: 5.5)
    
    static var previews: some View {
        NavigationView {
            BrewTimerView(showSelf: .constant(true), newBrew: newBrew)
                .environmentObject(GlobalSettings())
        }
        .previewDevice("iPhone 12 Pro Max")
    }
}
