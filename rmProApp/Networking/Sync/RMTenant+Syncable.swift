//
//  RMTenant+Syncable.swift
//  rmProApp
//

import Foundation

extension RMTenant: SyncableEntity {
    static var entityKey: String { "tenants" }
    var syncID: String { id }
    var updateDateString: String? { updateDate }
}
