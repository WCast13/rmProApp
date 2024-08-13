//
//  Notes.swift
//  rmProApp
//
//  Created by William Castellano on 8/8/24.
//

import Foundation

// MARK: From ChatGPT

/*
 Sites API call- Active Sites
 
 /Units?filters=Property.IsActive,eq,true
 
 /Units?embeds=Addresses,CreateUser,CurrentOccupancyStatus,CurrentOccupants,History,History.HistoryAttachments,HistoryNotes,HistorySystemNotes,Property&filters=Property.IsActive,eq,true&fields=Name
 
 /Units?embeds=Addresses,Leases,Leases.LeaseRenewals,Leases.Tenant,Leases.Tenant.SecurityDepositHeld&filters=Property.IsActive,eq,true&fields=Addresses,Leases
 
 /Units?embeds=Addresses,Leases,Leases.LeaseRenewals,Leases.Tenant,Leases.Tenant.SecurityDepositHeld&filters=Property.IsActive,eq,true&fields=Addresses,Leases,Name
 
 /Units?embeds=Addresses,CurrentOccupancyStatus,CurrentOccupants,Leases,PrimaryAddress,UserDefinedValues&filters=Property.IsActive,eq,true;SquareFootage,eq,44&fields=Addresses,CurrentOccupancyStatus,CurrentOccupants,IsVacant,Leases,Name,PropertyID,UnitID,UserDefinedValues
 
 /Units?embeds=Addresses,CurrentOccupancyStatus,CurrentOccupants,Leases,PrimaryAddress,PrimaryAddress.AddressType,UserDefinedValues&filters=Property.IsActive,eq,true&fields=Addresses,CurrentOccupancyStatus,CurrentOccupants,IsVacant,Leases,Name,PrimaryAddress,PropertyID,UnitID,UserDefinedValues
 
 GET Contacts?filters={filters}&embeds={embeds}&orderingOptions={orderingOptions}&fields={fields}
 
 /Contacts?embeds=Addresses,ContactType,PhoneNumbers,PhoneNumbers.PhoneNumberType,Tenant,Tenant.Addresses,Tenant.Leases,Tenant.Leases.Property,Tenant.Leases.Unit,Tenant.Leases.Unit.Property,Tenant.Property,UserDefinedValues&filters=Tenant.Property.IsActive,eq,true&fields=Addresses,AnnualIncome,ApplicantType,ContactID,ContactType,ContactTypeID,CreateDate,CreateUserID,DateOfBirth,Email,FirstName,IsActive,IsPrimary,IsShowOnBill,LastName,MiddleName,PhoneNumbers,Tenant,UpdateDate,UserDefinedValues,Vehicle
 
 /Contacts/342?embeds=Addresses,ContactType,PhoneNumbers,PhoneNumbers.PhoneNumberType,Tenant,Tenant.Addresses,Tenant.Leases,Tenant.Leases.Property,Tenant.Leases.Unit,Tenant.Leases.Unit.Property,Tenant.Property,UserDefinedValues&filters=Tenant.Property.IsActive,eq,true&fields=Addresses,AnnualIncome,ApplicantType,ContactID,ContactType,ContactTypeID,CreateDate,CreateUserID,DateOfBirth,Email,FirstName,IsActive,IsPrimary,IsShowOnBill,LastName,MiddleName,PhoneNumbers,Tenant,UpdateDate,UserDefinedValues,Vehicle
 */

