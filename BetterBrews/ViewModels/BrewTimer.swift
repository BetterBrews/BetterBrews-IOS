//
//  BrewTimer.swift
//  BetterBrews
//
//  Created by Colby Haskell on 8/18/21.
//

import SwiftUI

class BrewTimer: ObservableObject {
    @Published var deciSecondsElapsed: Int = 0
    var secondsElapsed: Int {
        deciSecondsElapsed/10
    }
    var minutesElapsed: Int {
        deciSecondsElapsed/600
    }
    
    //Time formatted to be displayed on timer screen
    var deciseconds: Int {
        return deciSecondsElapsed%10
    }
    var seconds: Int {
        return secondsElapsed%60
    }
    var minutes: Int {
        return minutesElapsed
    }
    
    @Published var mode: TimerMode = .stopped
    var decisecondsTimer: Timer?
    
    func toggle() {
        if(mode == .running) {
            pause()
        }
        else {
            start()
        }
    }
    
    func pause() {
        decisecondsTimer?.invalidate()
        mode = .paused
    }
    
    func start() {
        guard mode != .running else {
            return
        }
        mode = .running
        decisecondsTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            if(self?.mode == .running) {
                self?.deciSecondsElapsed += 1
            }
        }
    }
    
    func stop() {
        decisecondsTimer?.invalidate()
        deciSecondsElapsed = 0
        mode = .stopped
    }
    
    //Starts timer after 1 second
    func startDelayed() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: 1000000000), execute: start)
    }
    
    enum TimerMode {
        case running
        case stopped
        case paused
    }
}


