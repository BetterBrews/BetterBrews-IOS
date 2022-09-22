//
//  BrewEquipment.swift
//  BetterBrews
//
//  Created by Colby Haskell on 8/12/21.
//

import Foundation

struct BrewEquipment: Identifiable, Codable, Equatable {
    let id: Int
    let name: String
    let type: String
    let notes: String
    let estTime: Int // [mins]
    let filters: [String]
    var isFavorite: Bool = false
}

//TODO: Add Public API Functions
