//
//  BrewMethod.swift
//  BetterBrews
//
//  Created by Colby Haskell on 8/12/21.
//

import Foundation

//
//
//TODO: Add Brew Time
struct BrewEquipment: Identifiable, Codable {
    //TODO: Add estTime, suggested settings(coffee:water ratio, etc.)
    
    let id: Int
    let name: String
    let type: String
    let notes: String
    let estTime: Int //Time in minutes for typical brew
    var isFavorite: Bool = false
}
