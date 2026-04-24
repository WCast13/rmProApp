//
//  rmProAppTests.swift
//  rmProAppTests
//
//  Smoke tests + RMFilter serialization. The RMFilter format is what
//  every GET request ships as its filters= query parameter, so breaking
//  it silently breaks every list fetch.
//

import XCTest
@testable import rmProApp

final class RMFilterTests: XCTestCase {
    func testSingleFilterSerializesAsKeyCommaOpCommaValue() {
        let filter = RMFilter(key: "Status", operation: "ne", value: "Past")
        let queryItem = RMQuery.filters([filter])

        XCTAssertEqual(queryItem?.name, "filters")
        XCTAssertEqual(queryItem?.value, "Status,ne,Past")
    }

    func testMultipleFiltersJoinedWithSemicolons() {
        let filters = [
            RMFilter(key: "Status", operation: "ne", value: "Past"),
            RMFilter(key: "UpdateDate", operation: "gte", value: "2026-04-23T00:00:00Z"),
        ]
        let queryItem = RMQuery.filters(filters)

        XCTAssertEqual(queryItem?.value, "Status,ne,Past;UpdateDate,gte,2026-04-23T00:00:00Z")
    }

    func testEmptyFiltersReturnNilQueryItem() {
        XCTAssertNil(RMQuery.filters([]))
    }
}
