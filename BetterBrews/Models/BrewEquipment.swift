//
//  BrewEquipment.swift
//  BetterBrews
//
//  Created by Colby Haskell on 8/12/21.
//

import Foundation

//
//
//TODO: Add Brew Time
struct BrewEquipment: Identifiable, Codable, Equatable {
    let id: Int
    let name: String
    let type: String
    let notes: String
    let estTime: Int //Time in minutes for typical brew
    let filters: [String]
    var isFavorite: Bool = false
}
