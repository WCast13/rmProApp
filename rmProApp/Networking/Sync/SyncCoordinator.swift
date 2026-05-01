//
//  SyncCoordinator.swift
//  rmProApp
//

import Foundation

actor SyncCoordinator {
    static let shared = SyncCoordinator()

    private let defaults = UserDefaults.standard

    /// ISO8601 formatter RentManager accepts in filter values, e.g.
    /// "2026-04-23T00:00:00Z". Seconds precision, UTC `Z` suffix.
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

    /// Returns a RentManager-compatible date filter ("UpdateDate,ge,<iso>")
    /// when there's a prior sync, or nil (meaning: do a full pull).
    /// `ge` is RentManager's operator code for ≥; `gte`/`gteq` are rejected.
    func deltaFilter<E: SyncableEntity>(for type: E.Type) -> RMFilter? {
        guard let last = lastSyncDate(for: type) else { return nil }
        let iso = Self.rmDateFormatter.string(from: last)
        return RMFilter(key: "UpdateDate", operation: "ge", value: iso)
    }
}
