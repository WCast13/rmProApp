//
//  SwiftDataManager.swift
//  rmProApp
//
//  Created by William Castellano on 9/19/25.
//

import Foundation
import SwiftData

/// Generic SwiftData manager for CRUD operations on any model type
@MainActor
class SwiftDataManager {
    private var modelContext: ModelContext?

    static let shared = SwiftDataManager()

    private init() {}

    /// Set the ModelContext for SwiftData operations
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    // MARK: - Save Operations

    /// Save a single item to SwiftData
    func save<T: PersistentModel>(_ item: T) throws {
        guard let context = modelContext else {
            throw SwiftDataError.contextNotSet
        }

        context.insert(item)
        try context.save()
        print("✅ Saved \(T.self) to SwiftData")
    }

    /// Save multiple items to SwiftData
    func save<T: PersistentModel>(_ items: [T]) throws {
        guard let context = modelContext else {
            throw SwiftDataError.contextNotSet
        }

        for item in items {
            context.insert(item)
        }

        try context.save()
        print("✅ Saved \(items.count) \(T.self) items to SwiftData")
    }

    // MARK: - Load Operations

    /// Load all items of a specific type
    func loadAll<T: PersistentModel>(of type: T.Type, sortBy: [SortDescriptor<T>] = []) throws -> [T] {
        guard let context = modelContext else {
            throw SwiftDataError.contextNotSet
        }

        let descriptor = FetchDescriptor<T>(sortBy: sortBy)
        let items = try context.fetch(descriptor)
        print("✅ Loaded \(items.count) \(T.self) items from SwiftData")
        return items
    }

    /// Load items with a predicate filter
    func load<T: PersistentModel>(
        of type: T.Type,
        where predicate: Predicate<T>? = nil,
        sortBy: [SortDescriptor<T>] = [],
        limit: Int? = nil
    ) throws -> [T] {
        guard let context = modelContext else {
            throw SwiftDataError.contextNotSet
        }

        var descriptor = FetchDescriptor<T>(
            predicate: predicate,
            sortBy: sortBy
        )

        if let limit = limit {
            descriptor.fetchLimit = limit
        }

        let items = try context.fetch(descriptor)
        print("✅ Loaded \(items.count) \(T.self) items with predicate from SwiftData")
        return items
    }

    /// Load a single item by predicate
    func loadFirst<T: PersistentModel>(
        of type: T.Type,
        where predicate: Predicate<T>
    ) throws -> T? {
        let items = try load(of: type, where: predicate, limit: 1)
        return items.first
    }

    // MARK: - Delete Operations

    /// Delete a single item
    func delete<T: PersistentModel>(_ item: T) throws {
        guard let context = modelContext else {
            throw SwiftDataError.contextNotSet
        }

        context.delete(item)
        try context.save()
        print("✅ Deleted \(T.self) from SwiftData")
    }

    /// Delete multiple items
    func delete<T: PersistentModel>(_ items: [T]) throws {
        guard let context = modelContext else {
            throw SwiftDataError.contextNotSet
        }

        for item in items {
            context.delete(item)
        }

        try context.save()
        print("✅ Deleted \(items.count) \(T.self) items from SwiftData")
    }

    /// Delete all items of a specific type
    func deleteAll<T: PersistentModel>(of type: T.Type) throws {
        guard let context = modelContext else {
            throw SwiftDataError.contextNotSet
        }

        let descriptor = FetchDescriptor<T>()
        let items = try context.fetch(descriptor)

        for item in items {
            context.delete(item)
        }

        try context.save()
        print("✅ Deleted all \(items.count) \(T.self) items from SwiftData")
    }

    /// Delete items matching a predicate
    func delete<T: PersistentModel>(
        of type: T.Type,
        where predicate: Predicate<T>
    ) throws {
        guard let context = modelContext else {
            throw SwiftDataError.contextNotSet
        }

        let descriptor = FetchDescriptor<T>(predicate: predicate)
        let items = try context.fetch(descriptor)

        for item in items {
            context.delete(item)
        }

        try context.save()
        print("✅ Deleted \(items.count) \(T.self) items matching predicate from SwiftData")
    }

    // MARK: - Utility Operations

    /// Count items of a specific type
    func count<T: PersistentModel>(of type: T.Type, where predicate: Predicate<T>? = nil) throws -> Int {
        guard let context = modelContext else {
            throw SwiftDataError.contextNotSet
        }

        let descriptor = FetchDescriptor<T>(predicate: predicate)
        let items = try context.fetch(descriptor)
        return items.count
    }

    /// Check if any items exist matching a predicate
    func exists<T: PersistentModel>(of type: T.Type, where predicate: Predicate<T>) throws -> Bool {
        let count = try self.count(of: type, where: predicate)
        return count > 0
    }

    /// Replace all items of a type with new items (useful for API sync)
    func replaceAll<T: PersistentModel>(_ newItems: [T], of type: T.Type) throws {
        guard let context = modelContext else {
            throw SwiftDataError.contextNotSet
        }

        // Delete existing items
        let descriptor = FetchDescriptor<T>()
        let existingItems = try context.fetch(descriptor)

        for item in existingItems {
            context.delete(item)
        }

        // Add new items
        for item in newItems {
            context.insert(item)
        }

        try context.save()
        print("✅ Replaced all \(T.self) items with \(newItems.count) new items")
    }

    /// Save context manually (useful after batch operations)
    func saveContext() throws {
        guard let context = modelContext else {
            throw SwiftDataError.contextNotSet
        }

        try context.save()
        print("✅ Saved SwiftData context")
    }
}

// MARK: - Error Handling

enum SwiftDataError: LocalizedError {
    case contextNotSet
    case fetchFailed(String)
    case saveFailed(String)
    case deleteFailed(String)

    var errorDescription: String? {
        switch self {
        case .contextNotSet:
            return "SwiftData ModelContext has not been set"
        case .fetchFailed(let message):
            return "Failed to fetch data: \(message)"
        case .saveFailed(let message):
            return "Failed to save data: \(message)"
        case .deleteFailed(let message):
            return "Failed to delete data: \(message)"
        }
    }
}

// MARK: - Convenience Extensions

extension SwiftDataManager {
    /// Async wrapper for save operations
    func saveAsync<T: PersistentModel>(_ item: T) async throws {
        try save(item)
    }

    /// Async wrapper for save multiple operations
    func saveAsync<T: PersistentModel>(_ items: [T]) async throws {
        try save(items)
    }

    /// Async wrapper for load operations
    func loadAllAsync<T: PersistentModel>(of type: T.Type, sortBy: [SortDescriptor<T>] = []) async throws -> [T] {
        return try loadAll(of: type, sortBy: sortBy)
    }

    /// Async wrapper for delete operations
    func deleteAsync<T: PersistentModel>(_ item: T) async throws {
        try delete(item)
    }

    /// Async wrapper for delete all operations
    func deleteAllAsync<T: PersistentModel>(of type: T.Type) async throws {
        try deleteAll(of: type)
    }
}

// MARK: - Usage Examples in Comments

/*

 // MARK: Usage Examples

 // 1. Save a single item
 try SwiftDataManager.shared.save(userDefinedValue)

 // 2. Save multiple items
 try SwiftDataManager.shared.save(userDefinedValues)

 // 3. Load all items
 let allValues = try SwiftDataManager.shared.loadAll(of: RMUserDefinedValue.self)

 // 4. Load with sorting
 let sortedValues = try SwiftDataManager.shared.loadAll(
     of: RMUserDefinedValue.self,
     sortBy: [SortDescriptor(\.name)]
 )

 // 5. Load with predicate
 let filteredValues = try SwiftDataManager.shared.load(
     of: RMUserDefinedValue.self,
     where: #Predicate { $0.fieldType == "Text" }
 )

 // 6. Load first matching item
 let firstValue = try SwiftDataManager.shared.loadFirst(
     of: RMUserDefinedValue.self,
     where: #Predicate { $0.userDefinedFieldID == 123 }
 )

 // 7. Delete a single item
 try SwiftDataManager.shared.delete(userDefinedValue)

 // 8. Delete all items of a type
 try SwiftDataManager.shared.deleteAll(of: RMUserDefinedValue.self)

 // 9. Delete items matching predicate
 try SwiftDataManager.shared.delete(
     of: RMUserDefinedValue.self,
     where: #Predicate { $0.fieldType == "Obsolete" }
 )

 // 10. Replace all items (useful for API sync)
 try SwiftDataManager.shared.replaceAll(newUserDefinedValues, of: RMUserDefinedValue.self)

 // 11. Count items
 let count = try SwiftDataManager.shared.count(of: RMUserDefinedValue.self)

 // 12. Check if items exist
 let hasTextFields = try SwiftDataManager.shared.exists(
     of: RMUserDefinedValue.self,
     where: #Predicate { $0.fieldType == "Text" }
 )

 // 13. Async operations
 await SwiftDataManager.shared.saveAsync(userDefinedValue)
 let asyncValues = await SwiftDataManager.shared.loadAllAsync(of: RMUserDefinedValue.self)

 */