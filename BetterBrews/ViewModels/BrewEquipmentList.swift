//
//  BrewEquipmentList.swift
//  BetterBrews
//
//  Manages storage of brew equipment list
//  Data persists through stored JSON files, using the default
//
//  Created by Colby Haskell on 8/12/21.
//

import Foundation

class BrewEquipmentList: ObservableObject {
    @Published var brewEquipment: [BrewEquipment] = []
    enum MenuFilter: String, CaseIterable {
        case showAll
        case Favorites
        case Espresso
        case Immersion
        case Pourover
        case Drip
        case Custom
    }
    
    private static var documentsFolder: URL {
        do {
            return try FileManager.default.url(for: .documentDirectory,
                                               in: .userDomainMask,
                                               appropriateFor: nil,
                                               create: false)
        } catch {
            fatalError("Can't find documents directory.")
        }
    }
    //URL of saved user brew equipment list
    private static var fileURL: URL {
        return documentsFolder.appendingPathComponent("brews.data")
    }
    private var nextId: Int {
        brewEquipment.count
    }
    
    init() {
       loadBrews()
    }
    
    init(_ equipmentList: [BrewEquipment]) {
        self.brewEquipment = equipmentList
    }
    
    //returns a list of favorites
    var favorites:[BrewEquipment] {
        return brewEquipment.filter({ $0.isFavorite })
    }

    //MARK: - User Intents
    func addEquipment(name: String, type: String, notes: String, estTime: Int) {
        brewEquipment.append(BrewEquipment(id: nextId, name: name, type: type, notes: notes, estTime: estTime, filters: ["Custom"]))
        saveBrews()
    }
    func search(searchText: String) -> [BrewEquipment] {
        return brewEquipment.filter( { $0.name.contains(searchText) })
    }
    
    func addAsFavorite(_ id: Int) {
        guard let index = brewEquipment.firstIndex(where: { $0.id == id }) else {
            return
        }
        brewEquipment[index].isFavorite.toggle()
        saveBrews()
    }
    func reset() {
        loadDefaultBrews()
        saveBrews()
    }
    
    //MARK: - JSON Functions
    private func loadDefaultBrews() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            if let path = Bundle.main.path(forResource: "brews", ofType: "data") {
                do {
                    let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                    let brewEquipment = try JSONDecoder().decode([BrewEquipment].self, from: data)
                    DispatchQueue.main.async {
                        self?.brewEquipment = brewEquipment
                    }
                } catch {
                    //Fatal error if Default data either does not exist or is invalid format
                    fatalError(error.localizedDescription)
                }
            }
        }
    }
    private func loadBrews() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            do {
                //Take data from saved user file if it exists
                let data = try Data(contentsOf: Self.fileURL)
                //Attempt to Decode Brew Info from JSON data
                let brews = try JSONDecoder().decode([BrewEquipment].self, from: data)
                DispatchQueue.main.async {
                    self?.brewEquipment = brews
                }
            } catch {
                //Load default brews if saved data doesnt exist or is an invalid format
                self?.loadDefaultBrews()
            }
        }
    }
    private func saveBrews() {
        DispatchQueue.global(qos: .background).async {
            let encoder = JSONEncoder()
            do {
                let data = try encoder.encode(self.brewEquipment)
                try data.write(to: Self.fileURL)
                
            } catch {
                print("Unable to save custom brew equipment list")
            }
        }
    }
}
