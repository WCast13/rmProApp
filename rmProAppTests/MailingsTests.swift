//
//  MailingsTests.swift
//  rmProAppTests
//
//  Two pieces:
//   • Haven address `\r\n` split — called out in CLAUDE.md as the
//     silent-break hazard (without it the box number lands in the
//     middle of a street line on labels).
//   • ResidentDetailViewModel.buildTransactions merge — regression
//     guard for the old N×M same-reference bug that produced charges
//     × payments identical rows instead of a merged timeline.
//

import XCTest
@testable import rmProApp

// MARK: - Haven \r\n split

final class HavenAddressSplitTests: XCTestCase {
    func testSplitReturnsStreetAndBox() {
        let street = "123 Lake Dr\r\n45"
        let parts = street.components(separatedBy: "\r\n")

        XCTAssertEqual(parts.count, 2)
        XCTAssertEqual(parts.first, "123 Lake Dr")
        XCTAssertEqual(parts.last, "45")
    }

    func testSplitLeavesSingleLineAddressIntact() {
        // Pembroke addresses are single-line — no \r\n in them. Split
        // must not fabricate a second segment.
        let street = "1 Ocean Ave"
        let parts = street.components(separatedBy: "\r\n")

        XCTAssertEqual(parts.count, 1)
        XCTAssertEqual(parts.first, "1 Ocean Ave")
        XCTAssertEqual(parts.last, "1 Ocean Ave") // first == last
    }

    func testSplitPreservesWhitespaceInStreet() {
        let street = "  42  Ash St  \r\n  7  "
        let parts = street.components(separatedBy: "\r\n")

        XCTAssertEqual(parts.first, "  42  Ash St  ")
        XCTAssertEqual(parts.last, "  7  ")
    }
}

// MARK: - Transaction merge regression

final class TransactionMergeTests: XCTestCase {
    @MainActor
    func testMergeProducesOneEntryPerSourceRow() throws {
        let charges = try decode([RMCharge].self, from: """
        [
          {"ID": 1, "Amount": 100, "TransactionDate": "2026-04-01T00:00:00Z", "TransactionType": "Charge", "Comment": "Rent"},
          {"ID": 2, "Amount": 50,  "TransactionDate": "2026-04-05T00:00:00Z", "TransactionType": "Charge", "Comment": "Fee"}
        ]
        """)
        let payments = try decode([RMPayment].self, from: """
        [
          {"ID": 10, "Amount": 80, "TransactionDate": "2026-04-02T00:00:00Z", "TransactionType": "Payment", "Comment": "Ck#101"}
        ]
        """)
        let reversals = try decode([RMPaymentReversal].self, from: """
        [
          {"PaymentID": 10, "ReversalDate": "2026-04-03T00:00:00Z", "ReversalType": "NSF", "ReversalReason": "Bounced"}
        ]
        """)

        let vm = ResidentDetailViewModel(tenant: WCLeaseTenant())
        let merged = vm.buildTransactions(charges: charges, payments: payments, reversals: reversals)

        // One entry per source row — not the old N×M cartesian product.
        XCTAssertEqual(merged.count, 4)
    }

    @MainActor
    func testMergedEntriesAreDistinctInstances() throws {
        let charges = try decode([RMCharge].self, from: """
        [
          {"ID": 1, "Amount": 100, "TransactionDate": "2026-04-01T00:00:00Z", "TransactionType": "Charge"},
          {"ID": 2, "Amount": 50,  "TransactionDate": "2026-04-05T00:00:00Z", "TransactionType": "Charge"}
        ]
        """)

        let vm = ResidentDetailViewModel(tenant: WCLeaseTenant())
        let merged = vm.buildTransactions(charges: charges, payments: [], reversals: [])

        XCTAssertEqual(merged.count, 2)
        // Old bug: all appended entries were the same scratch WCTransaction
        // reference, so the array held N duplicate object identities.
        XCTAssertFalse(merged[0] === merged[1], "Each merged row must be a distinct instance.")
    }

    @MainActor
    func testMergedTimelineIsSortedNewestFirst() throws {
        let charges = try decode([RMCharge].self, from: """
        [
          {"ID": 1, "Amount": 100, "TransactionDate": "2026-01-01T00:00:00Z", "TransactionType": "Charge"},
          {"ID": 2, "Amount": 50,  "TransactionDate": "2026-04-05T00:00:00Z", "TransactionType": "Charge"},
          {"ID": 3, "Amount": 25,  "TransactionDate": "2026-02-15T00:00:00Z", "TransactionType": "Charge"}
        ]
        """)

        let vm = ResidentDetailViewModel(tenant: WCLeaseTenant())
        let merged = vm.buildTransactions(charges: charges, payments: [], reversals: [])

        XCTAssertEqual(merged.map(\.transactionDate), [
            "2026-04-05T00:00:00Z",
            "2026-02-15T00:00:00Z",
            "2026-01-01T00:00:00Z",
        ])
    }

    // MARK: helpers

    private func decode<T: Decodable>(_ type: T.Type, from json: String) throws -> T {
        let data = json.data(using: .utf8)!
        return try JSONDecoder().decode(type, from: data)
    }
}
