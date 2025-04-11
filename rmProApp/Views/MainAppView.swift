//
//  MainAppView.swift
//  rmProApp
//
//  Created by William Castellano on 4/3/25.
//

import SwiftUI

struct MainAppView: View {
    @State private var navigationPath = NavigationPath()
    @State private var havenTenants: [RMTenant] = []
    @State private var pembrokeTenants: [RMTenant] = []
    @State private var elapsedTime: Double = 0
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            HomeView(navigationPath: $navigationPath)
                .navigationTitle("Home") // Ensure a title is set for the root view
                .navigationDestination(for: AppDestination.self) { destination in
                    
                    switch destination {
                    case .home:
                        HomeView(navigationPath: $navigationPath)
                    case .rentIncreaseBuilder:
                        RentIncreaseNoticeBuilder(navigationPath: $navigationPath)
                    case .mailingLabels:
                        ContentView(navigationPath: $navigationPath)
                    case .documents:
                        DocumentsView(navigationPath: $navigationPath)
                    case .documentViewer(let url):
                        DocumentViewerView(documentURL: url, navigationPath: $navigationPath)
                    case .residentsHome:
                        ResidentsHomeView(navigationPath: $navigationPath)
                    case .havenResidents:
                        HavenResidentsView(navigationPath: $navigationPath)
                    case .pembrokeResidents:
                        PembrokeResidentsView(navigationPath: $navigationPath)
                    case .residentDetails:
                        ResidentDetailView(navigationPath: $navigationPath)
                    case .noticesBuilder(let unit):
                        ViolationBuilderView(navigationPath: $navigationPath, unit: unit)
                    case .specialTask:
                        GetBoxNumbersForUDF(navigationPath: $navigationPath)
                    }
                }
        }
        .onAppear {
            
            Task {
                await TokenManager.shared.refreshToken()
                
                let embeds: [TenantEmbedOption] = [
                    .addresses,
                    .addresses_AddressType,
                    .balance,
                    .charges,
                    .color,
                    .contacts,
                    .contacts_Addresses,
                    .contacts_ContactType,
                    .contacts_PhoneNumbers,
                    .contacts_PhoneNumbers_PhoneNumberType,
                    .contacts_UserDefinedValues,
                    .evictions,
                    .evictions_EvictionOutcome,
                    .evictions_EvictionWorkflowStage,
                    .history,
                    .leases,
                    .leases_Property,
                    .leases_Unit,
                    .leases_Unit_Property,
                    .leases_Unit_UnitType,
                    .loans,
                    .openBalance,
                    .openPrepays,
                    .openReceivables,
                    .openReceivables_ChargeType,
                    .payments,
                    .paymentReversals,
                    .primaryContact,
                    .primaryContact_PhoneNumbers,
                    .primaryContact_PhoneNumbers_PhoneNumberType,
                    .recurringCharges,
                    .recurringChargeSummaries,
                    .recurringChargeSummaries_ChargeType,
                    .securityDepositHeld,
                    .securityDepositSummaries,
                    .tenantBills,
                    .tenantChecks,
                    .userDefinedValues,
                    .vehicles
                ]
                
                
                let fields: [TenantFieldOption] = [
                    .addresses,
                    .balance,
                    .charges,
                    .colorID,
                    .comment,
                    .contacts,
                    .evictionID,
                    .evictions,
                    .firstName,
                    .history,
                    .historyEviction,
                    .historyEvictionNotes,
                    .lastName,
                    .leases,
                    .loans,
                    .name,
                    .openBalance,
                    .openReceivables,
                    .paymentReversals,
                    .payments,
                    .primaryContact,
                    .propertyID,
                    .recurringCharges,
                    .recurringChargeSummaries,
                    .securityDepositHeld,
                    .securityDepositSummaries,
                    .status,
                    .tenantDisplayID,
                    .tenantID,
                    .updateDate,
                    .updateUserID,
                    .userDefinedValues,
                    .vehicles
                ]
                
                let smallerEmbeds: [TenantEmbedOption] = [
                    .addresses,
                    .addresses_AddressType,
                    .balance,
                    .color,
                    .contacts,
                    .contacts_Addresses,
                    .contacts_ContactType,
                    .contacts_PhoneNumbers,
                    .contacts_PhoneNumbers_PhoneNumberType,
                    .contacts_UserDefinedValues,
                    .evictions,
                    .evictions_EvictionOutcome,
                    .evictions_EvictionWorkflowStage,
                    .leases,
                    .leases_Unit,
                    .leases_Unit_UnitType,
                    .loans,
                    .openBalance,
                    .openPrepays,
                    .openReceivables,
                    .openReceivables_ChargeType,
                    .primaryContact,
                    .primaryContact_PhoneNumbers,
                    .primaryContact_PhoneNumbers_PhoneNumberType,
                    .recurringCharges,
                    .recurringChargeSummaries,
                    .recurringChargeSummaries_ChargeType,
                    .securityDepositHeld,
                    .securityDepositSummaries,
                    .userDefinedValues,
                    .vehicles
                ]
                
                
                let smallerFields: [TenantFieldOption] = [
                    .addresses,
                    .balance,
                    .colorID,
                    .comment,
                    .contacts,
                    .evictionID,
                    .evictions,
                    .firstName,
                    .lastName,
                    .leases,
                    .loans,
                    .name,
                    .openBalance,
                    .openReceivables,
                    .primaryContact,
                    .propertyID,
                    .recurringCharges,
                    .recurringChargeSummaries,
                    .securityDepositHeld,
                    .securityDepositSummaries,
                    .status,
                    .tenantDisplayID,
                    .tenantID,
                    .updateDate,
                    .updateUserID,
                    .userDefinedValues,
                    .vehicles
                ]
                
                // Simple - Uses smallerEmbeds/smallerFields
//                let embedsString = smallerEmbeds.map { $0.rawValue }.joined(separator: ",")
//                let fieldsString = smallerFields.map { $0.rawValue }.joined(separator: ",")
                
                // All Data Needed- Uses embeds/fields
                let embedsString = embeds.map { $0.rawValue }.joined(separator: ",")
                let fieldsString = fields.map { $0.rawValue }.joined(separator: ",")
                
                let filtersStringHaven = [RMFilter(key: "PropertyID", operation: "eq", value: "3"),RMFilter(key: "Status", operation: "ne" , value: "Past")]
                let filtersStringPembroke = [RMFilter(key: "PropertyID", operation: "eq", value: "12"),RMFilter(key: "Status", operation: "ne" , value: "Past")]
                
                let pageSize: Int = 20000
                
//                let havenUrl = URLBuilder.shared.buildURL(endpoint: .tenants, embeds: embedsString, fields: fieldsString, filters: filtersStringHaven ,pageSize: pageSize)
//                let pembrokeUrl = URLBuilder.shared.buildURL(endpoint: .tenants, embeds: embedsString, fields: fieldsString, filters: filtersStringPembroke ,pageSize: pageSize)
                let singleTenantUrl = URLBuilder.shared.buildURL(endpoint: .tenants, embeds: embedsString, fields: fieldsString, id: "305")
                
                
                
                let startTime = Date()
                
                do {
//                    havenTenants = await RentManagerAPIClient.shared.request(url: havenUrl!, responseType: [RMTenant].self) ?? [RMTenant]()
//                    pembrokeTenants = await RentManagerAPIClient.shared.request(url: pembrokeUrl!, responseType: [RMTenant].self) ?? [RMTenant]()
                    let singleTenant = await RentManagerAPIClient.shared.request(url: URL(string: "https://trieq.api.rentmanager.com/Tenants?embeds=Charges,Payments&filters=Status,eq,Current;PropertyID,eq,12&fields=Charges,Name,OpenBalance,Payments")!, responseType: [RMTenant].self)
                    
                    let timeInterval = Date().timeIntervalSince(startTime)
                    elapsedTime = timeInterval
                    print(elapsedTime)
                    print(singleTenant?.first?.charges?.count ?? 0)
                    print(singleTenant?.first?.payments?.count ?? 0)
                }
                
//                print(havenTenants.count)
//                print(pembrokeTenants.count)
            }
        }
    }
}

enum AppDestination: Hashable {
    case home
    case rentIncreaseBuilder
    case mailingLabels
    case documents
    case documentViewer(URL)
    case residentsHome
    case havenResidents
    case pembrokeResidents
    case residentDetails
    case noticesBuilder(RMUnit)
    case specialTask
}
