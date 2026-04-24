//
//  RMUserDefinedValue+Syncable.swift
//  rmProApp
//

import Foundation

extension RMUserDefinedValue: SyncableEntity {
    static var entityKey: String { "udfs" }
    var syncID: String { id }
    var updateDateString: String? { updateDate }
}
