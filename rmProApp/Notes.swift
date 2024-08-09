//
//  Notes.swift
//  rmProApp
//
//  Created by William Castellano on 8/8/24.
//

import Foundation

// MARK: Sites Info
/*
 Sites API call- Active Sites
 
 /Units?filters=Property.IsActive,eq,true
 
 /Units?embeds=Addresses,CreateUser,CurrentOccupancyStatus,CurrentOccupants,History,History.HistoryAttachments,HistoryNotes,HistorySystemNotes,Property&filters=Property.IsActive,eq,true&fields=Name
 
 /Units?embeds=Addresses,Leases,Leases.LeaseRenewals,Leases.Tenant,Leases.Tenant.SecurityDepositHeld&filters=Property.IsActive,eq,true&fields=Addresses,Leases
 
 /Units?embeds=Addresses,Leases,Leases.LeaseRenewals,Leases.Tenant,Leases.Tenant.SecurityDepositHeld&filters=Property.IsActive,eq,true&fields=Addresses,Leases,Name
 
 /Units?embeds=Addresses,CurrentOccupancyStatus,CurrentOccupants,Leases,PrimaryAddress,UserDefinedValues&filters=Property.IsActive,eq,true;SquareFootage,eq,44&fields=Addresses,CurrentOccupancyStatus,CurrentOccupants,IsVacant,Leases,Name,PropertyID,UnitID,UserDefinedValues
 
 /Units?embeds=Addresses,CurrentOccupancyStatus,CurrentOccupants,Leases,PrimaryAddress,PrimaryAddress.AddressType,UserDefinedValues&filters=Property.IsActive,eq,true&fields=Addresses,CurrentOccupancyStatus,CurrentOccupants,IsVacant,Leases,Name,PrimaryAddress,PropertyID,UnitID,UserDefinedValues
 */
