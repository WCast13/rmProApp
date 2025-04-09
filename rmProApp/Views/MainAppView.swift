//
//  MainAppView.swift
//  rmProApp
//
//  Created by William Castellano on 4/3/25.
//

import SwiftUI

struct MainAppView: View {
    @State private var navigationPath = NavigationPath()
    
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
                    }
                }
        }
        .onAppear {
            
            
            let baseURL = "https://trieq.api.rentmanager.com/"
            
            let embeds: [TenantEmbedOption] = [.addresses, .addresses_AddressType, .balance, .color, .contacts, .contacts_Addresses, .contacts_ContactType, .contacts_PhoneNumbers, .contacts_PhoneNumbers_PhoneNumberType, .contacts_UserDefinedValues, .history, .leases, .leasesUnit, .loans]
            
            
            let fields: [TenantFieldOption] = [.addresses, .balance, .openBalance, .color, .colorID, .contacts, .leases, .loans, .name, .charges, .bills, .doNotAcceptChecks, .doNotAcceptPayments, .doNotChargeLateFees, .doNotAllowTWAPayments, .isDoNotAcceptPartialPayments]
            
            let embedsString = embeds.map { $0.rawValue }.joined(separator: ",")
            let fieldsString = fields.map { $0.rawValue }.joined(separator: ",")
            let filtersString = [RMFilter(key: "PropertyID", operation: "eq", value: "3")].map { $0.queryString }.joined(separator: ";")
            let pageSize: Int = 20000
            
            var queryItems: [URLQueryItem] = []
            queryItems.append(URLQueryItem(name: "embeds", value: embedsString))
            queryItems.append(URLQueryItem(name: "fields", value: fieldsString))
            queryItems.append(URLQueryItem(name: "filters", value: filtersString))
            queryItems.append(URLQueryItem(name: "pageSize", value: String(pageSize)))
            
            let finalOutput = baseURL + queryItems.map(\.self).map(\.description).joined(separator: "&")
            print(finalOutput)
           
            
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
}
