//
//  RMDataManager.swift
//  rmProApp
//
//  Created by William Castellano on 9/19/25.
//

import Foundation

@MainActor
class RMDataManager: ObservableObject {
    
    @Published var unitsWithBasicData: [RMUnit] = []
    @Published var vacantUnits: [RMUnit] = []
    
    static let shared = RMDataManager()
    
    private init() {}
    
    func loadUnitsWithBasicData() async {
        let unitEmbeds: [UnitEmbedOption] = [ .addresses, .isVacant, .leases, .unitType]
        let unitFields: [UnitFieldOption] = [ .addresses, .leases, .name, .unitType, .isVacant, .propertyID]
        
        let fullEmbedsString = unitEmbeds.map { $0.rawValue }.joined(separator: ",")
        let fullFieldsString = unitFields.map { $0.rawValue }.joined(separator: ",")
        
        let unitFilters = RMFilter(key: "Property.IsActive", operation: "eq", value: "true")
        let unitsURL = URLBuilder.shared.buildURL(endpoint: .units, embeds: fullEmbedsString, fields: fullFieldsString, filters: [unitFilters])!
        
        unitsWithBasicData =  await RentManagerAPIClient.shared.request(url: unitsURL, responseType: [RMUnit].self) ?? []
        vacantUnits = unitsWithBasicData.filter { $0.isVacant == true && $0.name?.components(separatedBy: " ").last != "Loan" }
        
        print("\n\n")
        print("Units: \(unitsWithBasicData.count)")
        print("Vacant Units: \(vacantUnits.count)")
    }
    
    func loadUnits() async {
        let unitEmbeds: [UnitEmbedOption] = [ .addresses, .currentOccupants, .isVacant, .primaryAddress, .property, .property_Addresses, .leases_Tenant, .leases, .unitType]
        let unitFields: [UnitFieldOption] = [ .addresses, .currentOccupants, .isVacant, .leases, .name, .primaryAddress, .property, .propertyID, .unitType, .userDefinedValues]
        
        let fullEmbedsString = unitEmbeds.map { $0.rawValue }.joined(separator: ",")
        let fullFieldsString = unitFields.map { $0.rawValue }.joined(separator: ",")
        
        let unitFilters = RMFilter(key: "Property.IsActive", operation: "eq", value: "true")
        let unitsURL = URLBuilder.shared.buildURL(endpoint: .units, embeds: fullEmbedsString, fields: fullFieldsString, filters: [unitFilters])!
        
        unitsWithBasicData =  await RentManagerAPIClient.shared.request(url: unitsURL, responseType: [RMUnit].self) ?? []
        vacantUnits = unitsWithBasicData.filter { $0.isVacant == true && $0.name?.components(separatedBy: " ").last != "Loan" }
        
        print("\n\n")
        print("Units: \(unitsWithBasicData.count)")
        print("Vacant Units: \(vacantUnits.count)")
    }
    
    /*
     {{baseURL}}/Units?filters={{propertyIDFilter}}&embeds=CurrentOccupants,PrimaryAddress,Property.Addresses,UnitType,Leases,Leases.Tenant,UserDefinedValues&fields=CurrentOccupants,Name,PrimaryAddress,PropertyID,UnitType,Leases,UserDefinedValues
     */
    
    
    func loadUserDefinedValues() async -> [RMUserDefinedValue] {
        let userDefinedFieldsURL = URLBuilder.shared.buildURL(endpoint: .userDefinedFields)!
        
        let userDefinedValues: [RMUserDefinedValue] = await RentManagerAPIClient.shared.request(url: userDefinedFieldsURL, responseType: [RMUserDefinedValue].self) ?? []
        
        return userDefinedValues
    }
}

