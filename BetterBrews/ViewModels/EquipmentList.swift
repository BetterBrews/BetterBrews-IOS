//
//  BrewMethodList.swift
//  BetterBrews
//
//  Created by Colby Haskell on 8/12/21.
//

import Foundation

class EquipmentList: ObservableObject {
    @Published var brewEquipment: [BrewEquipment] = []
    
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
    func addBrew(name: String, type: String, notes: String, estTime: Int) {
        brewEquipment.append(BrewEquipment(id: nextId, name: name, type: type, notes: notes, estTime: estTime))
        saveBrews()
    }
    
    func addAsFavorite(_ id: Int) {
        guard let index = brewEquipment.firstIndex(where: { $0.id == id }) else {
            return
        }
        brewEquipment[index].isFavorite.toggle()
        saveBrews()
    }
    
    //MARK: - JSON Functions
    private func loadDefaultBrews() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            let decoder = JSONDecoder()
            if let path = Bundle.main.path(forResource: "brews", ofType: "data") {
                do {
                    let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                    DispatchQueue.main.async {
                        self?.brewEquipment = try! decoder.decode([BrewEquipment].self, from: data)
                    }
                } catch {
                    print(error)
                }
            }
        }
    }
    private func loadBrews() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let data = try? Data(contentsOf: Self.fileURL) else {
                self?.loadDefaultBrews()
                return
            }
            var brews = [BrewEquipment]()
            do {
                brews = try JSONDecoder().decode([BrewEquipment].self, from: data)
            } catch {
                print(error)
            }
            print(brews.count)
            DispatchQueue.main.async {
                self?.brewEquipment = brews
            }
        }
    }
    private func saveBrews() {
        DispatchQueue.global(qos: .background).async {
            let encoder = JSONEncoder()
            guard let data = try? encoder.encode(self.brewEquipment) else {
                fatalError("Error encoding brew list")
            }
            do {
                try data.write(to: Self.fileURL)
            } catch {
                fatalError("Cant save to JSON file")
            }
        }
    }
}
