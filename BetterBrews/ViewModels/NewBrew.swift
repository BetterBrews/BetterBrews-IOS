//
//  NewBrew.swift
//  BetterBrews
//
//  Created by Colby Haskell on 8/17/21.
//

import Foundation

class NewBrew: ObservableObject {
    @Published var brew: Brew
    private var pastBrew: PastBrew?
    
    var brewMinutes: Int {
        get {
            if(brew.brewTime == nil) {
                brew.brewTime = 0
            }
            return Int(brew.brewTime!)
        }
        set {
            if(brew.brewTime != nil) {
                brew.brewTime = brew.brewTime! - Double(Int(brew.brewTime!)) + Double(newValue)
            }
            else {
                brew.brewTime = Double(newValue)
            }
        }
    }
    
    var brewSeconds: Int {
        get {
            if(brew.brewTime == nil) {
                brew.brewTime = 0
            }
            return Int(brew.brewTime!*100)%100
        }
        set {
            if(brew.brewTime != nil) {
                brew.brewTime = Double(Int(brew.brewTime!)) + (Double(newValue%60)/100)
            }
            else {
                brew.brewTime = Double(newValue%60)/100
            }
        }
    }
    
    init(_ method: BrewEquipment) {
        brew = Brew(method)
    }
    
    func save() {
        BrewsManager.saveBrew(brew)
    }
    
    func update() {
        if(pastBrew == nil) {
            BrewsManager.saveBrew(brew)
        }
        else {
            BrewsManager.update(pastBrew!, with: brew)
        }
    }
    
    init(from pastBrew: PastBrew) {
        brew = Brew(pastBrew: pastBrew)
        self.pastBrew = pastBrew
    }
    
    /* For Preview Use Only */
    init(method: BrewEquipment, beanName: String, grind: String, brewTime: Double, waterTemp: Int, waterAmount: Double, coffeeAmount: Double) {
        let bean = Bean(context: PersistenceController.preview.container.viewContext)
        bean.name = beanName
        
        brew = Brew(method)
        brew.bean = bean
        brew.grindSize = GrindSize(rawValue: grind)!
        brew.brewTime = brewTime
        brew.temperatureString = String(waterTemp)
        brew.waterVolumeString = String(waterAmount)
        brew.coffeeAmountString = String(coffeeAmount)
    }
}
