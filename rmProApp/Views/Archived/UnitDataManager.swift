//
//  UnitDataManager.swift
//  rmProApp
//
//  Created by William Castellano on 4/14/25.
//

import Foundation

@MainActor
class UnitDataManager: ObservableObject {
    
    @Published var unitsWithBasicData: [RMUnit] = []
    @Published var vacantUnits: [RMUnit] = []
    
    static let shared = UnitDataManager()
    
    private init() {}
    
    func loadUnitsWithBasicData() async {
        let unitEmbeds: [UnitEmbedOption] = [ .addresses, .isVacant, .leases, .unitType]
        let unitFields: [UnitFieldOption] = [ .addresses, .leases, .name, .unitType, .isVacant]
        
        let fullEmbedsString = unitEmbeds.map { $0.rawValue }.joined(separator: ",")
        let fullFieldsString = unitFields.map { $0.rawValue }.joined(separator: ",")
        
        let unitFilters = RMFilter(key: "Property.IsActive", operation: "eq", value: "true")
        let unitsURL = URLBuilder.shared.buildURL(endpoint: .units, embeds: fullEmbedsString, fields: fullFieldsString, filters: [unitFilters])!
        
        unitsWithBasicData =  await RentManagerAPIClient.shared.request(url: unitsURL, responseType: [RMUnit].self) ?? []
        vacantUnits = unitsWithBasicData.filter { $0.isVacant == true && $0.name?.components(separatedBy: " ").last != "Loan" }
        
        print("\n\n")
        print(vacantUnits.count)
    }
}
