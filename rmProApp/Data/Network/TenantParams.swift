//
//  TenantParams.swift
//  rmProApp
//
//  Created by William Castellano on 4/8/25.
//

import Foundation

enum TenantEmbeds: String, CaseIterable {
    case addresses = "Addresses"
    case addresses_AddressType = "Addresses.AddressType"
    case balance = "Balance"
    case charges = "Charges"
    case charges_ChargeType = "Charges.ChargeType"
    case color = "Color"
    case contacts = "Contacts"
    case contacts_Addresses = "Contacts.Addresses"
    case contacts_ContactType = "Contacts.ContactType"
    case contacts_Image = "Contacts.Image"
    case contacts_PhoneNumbers = "Contacts.PhoneNumbers"
    case contacts_PhoneNumbers_PhoneNumberType = "Contacts.PhoneNumbers.PhoneNumberType"
    case contacts_UserDefinedValues = "Contacts.UserDefinedValues"
    case createUser = "CreateUser"
    case creditReversals = "CreditReversals"
    case credits = "Credits"
    case evictions_EvictionOutcome = "Evictions.EvictionOutcome"
    case evictions = "Evictions"
    case evictions_EvictionWorkflowStage = "Evictions.EvictionWorkflowStage"
    case history = "History"
    case historyCalls = "HistoryCalls"
    case history_HistoryCategory = "History.HistoryCategory"
    case historyEmails = "HistoryEmails"
    case historyEviction = "HistoryEviction"
    case historyEvictionNotes = "HistoryEvictionNotes"
    case history_HistoryAttachments = "History.HistoryAttachments"
    case history_HistoryAttachmentsFile = "History.HistoryAttachments.File"
    case historyNotes = "HistoryNotes"
    case historySystemNotes = "HistorySystemNotes"
    case historyViolationNotes = "HistoryViolationNotes"
    case historyVisits = "HistoryVisits"
    case historyWebAccountNotes = "HistoryWebAccountNotes"
    case invoicesInvoiceDetails = "Invoices.InvoiceDetails"
    case invoices = "Invoices"
    case leases_Property = "Leases.Property"
    case leases_Property_Addresses = "Leases.Property.Addresses"
    case leases_RetailSales = "Leases.RetailSales"
    case leases = "Leases"
    case leases_Unit = "Leases.Unit"
    case leases_Unit_Addresses = "Leases.Unit.Addresses"
    case leases_Unit_Property = "Leases.Unit.Property"
    case leases_Unit_PropertyAddresses = "Leases.Unit.Property.Addresses"
    case leases_Unit_UnitType = "Leases.Unit.UnitType"
    case loans = "Loans"
    case openBalance = "OpenBalance"
    case openPrepays = "OpenPrepays"
    case openReceivables = "OpenReceivables"
    case openReceivables_ChargeType = "OpenReceivables.ChargeType"
    case paymentReversals = "PaymentReversals"
    case payments = "Payments"
    case primaryContact = "PrimaryContact"
    case primaryContact_PhoneNumbers = "PrimaryContact.PhoneNumbers"
    case primaryContact_PhoneNumbers_PhoneNumberType = "PrimaryContact.PhoneNumbers.PhoneNumberType"
    case property = "Property"
    case propertyAddresses = "Property.Addresses"
    case prospect = "Prospect"
    case recurringCharges = "RecurringCharges"
    case recurringChargeSummaries = "RecurringChargeSummaries"
    case recurringChargeSummaries_ChargeType = "RecurringChargeSummaries.ChargeType"
    case rmVoIPCallHistory = "RMVoIPCallHistory"
    case screenings = "Screenings"
    case screeningStatus = "ScreeningStatus"
    case securityDepositHeld = "SecurityDepositHeld"
    case securityDepositSummaries = "SecurityDepositSummaries"
    case tasks = "Tasks"
    case tasks_TaskUsers = "Tasks.TaskUsers"
    case tenantBills = "TenantBills"
    case tenantChecks = "TenantChecks"
    case transactions = "Transactions"
    case updateUser = "UpdateUser"
    case userDefinedValues = "UserDefinedValues"
    case userDefinedValuesAttachment = "UserDefinedValues.Attachment"
    case vehicles = "Vehicles"
    case violations = "Violations"
    case webUserAccounts_WebUserAccountAutomaticPaymentSetting = "WebUserAccounts.WebUserAccountAutomaticPaymentSetting"
    case webUserAccounts = "WebUserAccounts"
    case webUserAccounts_WebUser = "WebUserAccounts.WebUser"
    case webUsers = "WebUsers"
}

enum TenantFields: String, CaseIterable {
    case accountStatements = "AccountStatements"
    case accountType = "AccountType"
    case addresses = "Addresses"
    case appointments = "Appointments"
    case balance = "Balance"
    case billableExpenses = "BillableExpenses"
    case charges = "Charges"
    case checkPayeeName = "CheckPayeeName"
    case checks = "Checks"
    case color = "Color"
    case colorID = "ColorID"
    case comment = "Comment"
    case contacts = "Contacts"
    case createDate = "CreateDate"
    case createUser = "CreateUser"
    case createUserID = "CreateUserID"
    case creditReversals = "CreditReversals"
    case credits = "Credits"
    case doNotAcceptChecks = "DoNotAcceptChecks"
    case doNotAcceptPayments = "DoNotAcceptPayments"
    case doNotAllowTWAPayments = "DoNotAllowTWAPayments"
    case doNotChargeLateFees = "DoNotChargeLateFees"
    case doNotPrintStatements = "DoNotPrintStatements"
    case doNotSendARAutomationNotifications = "DoNotSendARAutomationNotifications"
    case evictionID = "EvictionID"
    case evictions = "Evictions"
    case failedCalls = "FailedCalls"
    case firstContact = "FirstContact"
    case firstName = "FirstName"
    case history = "History"
    case historyCalls = "HistoryCalls"
    case historyEmails = "HistoryEmails"
    case historyEviction = "HistoryEviction"
    case historyEvictionNotes = "HistoryEvictionNotes"
    case historyNotes = "HistoryNotes"
    case historySystemNotes = "HistorySystemNotes"
    case historyViolationNotes = "HistoryViolationNotes"
    case historyVisits = "HistoryVisits"
    case historyWebAccountNotes = "HistoryWebAccountNotes"
    case historyWithUnitHistory = "HistoryWithUnitHistory"
    case inListItemMode = "InListItemMode"
    case invoices = "Invoices"
    case isAccountGroupMaster = "IsAccountGroupMaster"
    case isCompany = "IsCompany"
    case isDoNotAcceptPartialPayments = "IsDoNotAcceptPartialPayments"
    case isProspect = "IsProspect"
    case isShowCommentBanner = "IsShowCommentBanner"
    case lastContact = "LastContact"
    case lastName = "LastName"
    case lastNameFirstName = "LastNameFirstName"
    case lateFees = "LateFees"
    case lateFeeSetup = "LateFeeSetup"
    case leases = "Leases"
    case loans = "Loans"
    case name = "Name"
    case openBalance = "OpenBalance"
    case openPrepays = "OpenPrepays"
    case openReceivables = "OpenReceivables"
    case paymentReversals = "PaymentReversals"
    case payments = "Payments"
    case postingEndDate = "PostingEndDate"
    case postingStartDate = "PostingStartDate"
    case primaryContact = "PrimaryContact"
    case property = "Property"
    case propertyID = "PropertyID"
    case prospect = "Prospect"
    case recurringCharges = "RecurringCharges"
    case recurringChargeSummaries = "RecurringChargeSummaries"
    case rentDueDay = "RentDueDay"
    case rentPeriod = "RentPeriod"
    case revenueRenewals = "RevenueRenewals"
    case rmVoIPCallHistory = "RMVoIPCallHistory"
    case screenings = "Screenings"
    case screeningStatus = "ScreeningStatus"
    case securityDepositHeld = "SecurityDepositHeld"
    case securityDepositSummaries = "SecurityDepositSummaries"
    case sourceCustomerID = "SourceCustomerID"
    case statementMethod = "StatementMethod"
    case status = "Status"
    case tasks = "Tasks"
    case tenantBills = "TenantBills"
    case tenantChecks = "TenantChecks"
    case tenantDisplayID = "TenantDisplayID"
    case tenantID = "TenantID"
    case totalCalls = "TotalCalls"
    case totalEmails = "TotalEmails"
    case totalVisits = "TotalVisits"
    case transactions = "Transactions"
    case transferDate = "TransferDate"
    case transferGroupID = "TransferGroupID"
    case twaExpirationDate = "TWAExpirationDate"
    case updateDate = "UpdateDate"
    case updateUser = "UpdateUser"
    case updateUserID = "UpdateUserID"
    case userDefinedValues = "UserDefinedValues"
    case vehicles = "Vehicles"
    case violations = "Violations"
    case webMessage = "WebMessage"
    case webUserAccounts = "WebUserAccounts"
    case webUsers = "WebUsers"
}

extension TenantEmbeds {

    static let fullEmbeds: [TenantEmbeds] = [
        .addresses, .addresses_AddressType, .balance, .charges, .color, .contacts, .contacts_Addresses, .contacts_ContactType, .contacts_PhoneNumbers, .contacts_PhoneNumbers_PhoneNumberType, .contacts_UserDefinedValues, .evictions, .evictions_EvictionOutcome, .evictions_EvictionWorkflowStage, .history, .leases, .leases_Property, .leases_Unit, .leases_Unit_Property, .leases_Unit_Addresses, .leases_Unit_UnitType, .loans, .openBalance, .openPrepays, .openReceivables, .openReceivables_ChargeType, .payments, .paymentReversals, .primaryContact, .primaryContact_PhoneNumbers, .primaryContact_PhoneNumbers_PhoneNumberType,  .recurringChargeSummaries, .recurringChargeSummaries_ChargeType, .securityDepositHeld, .securityDepositSummaries, .tenantBills, .tenantChecks, .userDefinedValues, .vehicles
    ]
    
    static let simpleEmbeds: [TenantEmbeds] = [
        .addresses, .addresses_AddressType, .balance, .color, .contacts, .contacts_PhoneNumbers, .contacts_PhoneNumbers_PhoneNumberType, .evictions, .evictions_EvictionOutcome, .evictions_EvictionWorkflowStage, .leases, .leases_Unit, .leases_Unit_UnitType, .leases_Unit_Addresses, .loans, .openBalance, .openPrepays, .openReceivables, .openReceivables_ChargeType, .paymentReversals ,  .recurringChargeSummaries, .securityDepositHeld, .securityDepositSummaries, .userDefinedValues, .vehicles
    ]

    static let baseEmbeds: [TenantEmbeds] = [
        .balance, .color, .leases, .leases_Unit, .leases_Unit_UnitType, .leases_Unit_Addresses, .loans, .openBalance, .openReceivables, .openReceivables_ChargeType, .securityDepositHeld, .userDefinedValues
    ]
    
    static let bareEmbeds: [TenantEmbeds] = [
        .balance, .color, .openBalance, .openReceivables, .openReceivables_ChargeType, .securityDepositHeld
    ]
    
    static let leaseEmbeds: [TenantEmbeds] = [.leases, .leases_Unit, .leases_Unit_UnitType, .leases_Unit_Addresses]
    static let addressEmbeds: [TenantEmbeds] = [.addresses, .addresses_AddressType]
    static let contactsEmbeds: [TenantEmbeds] = [.contacts, .contacts_PhoneNumbers, .contacts_PhoneNumbers_PhoneNumberType]
    static let udfEmbeds: [TenantEmbeds] = [.userDefinedValues]
    static let historyEmbeds: [TenantEmbeds] = [.history, .historyCalls, .historyEviction, .historyEvictionNotes, .historyViolationNotes]
    static let loanEmbeds: [TenantEmbeds] = [.loans]
    
    static let transactionsEmbeds: [TenantEmbeds] = [.charges, .charges_ChargeType, .payments, .paymentReversals]
    
   
    
    
    

}

extension TenantFields {
    
    static let fullFields: [TenantFields] = [
    .addresses, .balance, .charges, .colorID, .comment, .contacts, .evictionID, .evictions, .firstName, .history, .historyEviction, .historyEvictionNotes, .lastName, .leases, .loans, .name, .openBalance, .openReceivables, .payments, .paymentReversals, .primaryContact, .propertyID,  .recurringChargeSummaries, .securityDepositHeld, .securityDepositSummaries, .status, .tenantDisplayID, .tenantID, .updateDate, .updateUserID, .userDefinedValues, .vehicles
]
    
    static let simpleFields: [TenantFields] = [
        .addresses, .balance, .colorID, .comment, .contacts, .evictionID, .evictions, .firstName, .lastName, .leases, .loans, .name, .openBalance, .openReceivables, .paymentReversals, .propertyID,  .recurringChargeSummaries, .securityDepositHeld, .securityDepositSummaries, .status, .tenantDisplayID, .tenantID, .updateDate, .updateUserID, .userDefinedValues
    ]

    static let baseFields: [TenantFields] = [
         .balance, .colorID, .comment, .firstName, .lastName, .leases, .loans, .name, .openBalance, .openReceivables, .propertyID,  .recurringChargeSummaries, .securityDepositHeld, .status, .tenantDisplayID, .tenantID, .updateDate, .updateUserID, .userDefinedValues
    ]
    
    static let bareFields: [TenantFields] = [
             .balance, .colorID, .comment, .firstName, .lastName, .name, .openBalance, .openReceivables, .propertyID, .securityDepositHeld, .status, .tenantDisplayID, .tenantID, .updateDate, .updateUserID
        ]
    
    static let leaseFields: [TenantFields] = [.leases, tenantID, .firstName, .lastName, .name]
    static let addressFields: [TenantFields] = [.addresses]
    static let contactFields: [TenantFields] = [.contacts]
    static let udfFields: [TenantFields] = [.userDefinedValues]
    static let historyFields: [TenantFields] = [.history, .historyCalls, .historyNotes, .historyEviction, .historyEvictionNotes]
    static let loanFields: [TenantFields] = [.loans]
    
    static let transactionsFields: [TenantFields] = [.charges, .payments, .paymentReversals]
    
    
    /*
     Removeing: Addresses, Contacts, UDF?, History, Recurring Charges Summaries, Security Deposit Summaries, Payment Reversals, Evictions
     */
    

    
    /*
     Removes: Leases, Loans, UDFs- Should break App
     */
    
    
    
    /*
     Removeing: Addresses, Contacts, UDF?, History, Recurring Charges Summaries, Security Deposit Summaries, Payment Reversals, Evictions, Vehicles
     */
    
    
    
    /*
     Removes: Leases, Loans, UDFs- Should break App
     */
    

}
