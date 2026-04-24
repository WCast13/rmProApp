//
//  RMUnit+Syncable.swift
//  rmProApp
//

import Foundation

extension RMUnit: SyncableEntity {
    static var entityKey: String { "units" }
    var syncID: String { id }
    var updateDateString: String? { updateDate }
}
