//
//  BrewTimer.swift
//  BetterBrews
//
//  Created by Colby Haskell on 8/18/21.
//

import SwiftUI

class BrewTimer: ObservableObject {
    @Published var millisecondsElapsed: Int = 0
    @Published var secondsElapsed: Int = 0
    @Published var minutesElapsed: Int = 0
    @Published var mode: TimerMode = .stopped
    var secondsTimer: Timer?
    var minutesTimer: Timer?
    var millisecondsTimer: Timer?
    
    func toggle() {
        if(mode == .running) {
            pause()
        }
        else {
            start()
        }
    }
    
    func pause() {
        mode = .paused
    }
    
    func start() {
        guard mode != .running else {
            return
        }
        mode = .running
        millisecondsTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            if(self?.mode == .running) {
                if(self?.millisecondsElapsed == 9) {
                    self?.millisecondsElapsed = 0
                }
                else {
                    self?.millisecondsElapsed += 1
                }
            }
        }
        secondsTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            if(self?.mode == .running) {
                if(self?.secondsElapsed == 59) {
                    self?.secondsElapsed = 0
                }
                else {
                    self?.secondsElapsed += 1
                }
            }
        }
        minutesTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] timer in
            if(self?.mode == .running) {
                if(self?.minutesElapsed == 59) {
                    self?.minutesElapsed = 0
                }
                else {
                    self?.minutesElapsed += 1
                }
            }
        }
    }
    
    func stop() {
        secondsTimer?.invalidate()
        minutesTimer?.invalidate()
        millisecondsTimer?.invalidate()
        secondsElapsed = 0
        minutesElapsed = 0
        millisecondsElapsed = 0
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


