//
//  NewBrew.swift
//  BetterBrews
//
//  Created by Colby Haskell on 8/17/21.
//

import Foundation

class NewBrew: ObservableObject {
    @Published var brew: Brew
    
    init(_ method: BrewEquipment) {
        brew = Brew(method)
    }
    
    func save() {
        //
        //
        //  UPDATE THIS
        //
        //
        BrewsManager.saveBrew(brew)
    }
    
    //For Preview Use
    init(method: BrewEquipment, beanName: String, grind: String, brewTime: Double, waterTemp: Int, waterAmount: Double, coffeeAmount: Double) {
        let bean = Bean(context: PersistenceController.preview.container.viewContext)
        bean.name = beanName
        
        brew = Brew(method)
        brew.bean = bean
        brew.grindSize = GrindSize(rawValue: grind)!
        brew.brewTime = brewTime
        brew.temperatureString = String(waterTemp)
        brew.waterAmountString = String(waterAmount)
        brew.coffeeAmountString = String(coffeeAmount)
    }
}
