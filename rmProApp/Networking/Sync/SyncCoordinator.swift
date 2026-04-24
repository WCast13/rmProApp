//
//  SyncCoordinator.swift
//  rmProApp
//

import Foundation

actor SyncCoordinator {
    static let shared = SyncCoordinator()

    private let defaults = UserDefaults.standard

    /// ISO8601 formatter RentManager accepts in filter values
    /// (e.g. "2026-04-23T00:00:00"). Seconds precision, no timezone suffix.
    private static let rmDateFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f
    }()

    func lastSyncDate<E: SyncableEntity>(for _: E.Type) -> Date? {
        defaults.object(forKey: E.lastSyncDateKey) as? Date
    }

    func markSynced<E: SyncableEntity>(_: E.Type, at date: Date = Date()) {
        defaults.set(date, forKey: E.lastSyncDateKey)
    }

    func resetSyncDate<E: SyncableEntity>(for _: E.Type) {
        defaults.removeObject(forKey: E.lastSyncDateKey)
    }

    /// Returns a RentManager-compatible date filter string ("UpdateDate,gte,<iso>")
    /// when there's a prior sync, or nil (meaning: do a full pull).
    func deltaFilter<E: SyncableEntity>(for type: E.Type) -> RMFilter? {
        guard let last = lastSyncDate(for: type) else { return nil }
        let iso = Self.rmDateFormatter.string(from: last)
        return RMFilter(key: "UpdateDate", operation: "gte", value: iso)
    }
}
