//
//  SyncableEntity.swift
//  rmProApp
//

import Foundation

protocol SyncableEntity {
    static var entityKey: String { get }
    var syncID: String { get }
    var updateDateString: String? { get }
}

extension SyncableEntity {
    static var lastSyncDateKey: String { "sync.lastSyncDate.\(entityKey)" }
}
