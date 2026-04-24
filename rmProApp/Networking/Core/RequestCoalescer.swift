//
//  RequestCoalescer.swift
//  rmProApp
//

import Foundation

actor RequestCoalescer {
    private var inFlight: [String: Task<Data, Error>] = [:]

    func run(key: String, _ operation: @Sendable @escaping () async throws -> Data) async throws -> Data {
        if let existing = inFlight[key] {
            return try await existing.value
        }

        let task = Task<Data, Error> {
            try await operation()
        }
        inFlight[key] = task

        defer { inFlight[key] = nil }
        return try await task.value
    }
}
