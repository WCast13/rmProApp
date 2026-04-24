//
//  NetworkingTests.swift
//  rmProAppTests
//
//  Typed request URL composition, RMAPIError status mapping, and
//  SyncCoordinator delta-filter generation. These are the pieces that
//  underpin every read from the RentManager API — if any of them drift
//  silently, whole screens stop fetching correctly.
//

import XCTest
@testable import rmProApp

// MARK: - Typed Request URL Composition

final class GetTenantsRequestTests: XCTestCase {
    func testDefaultInitSendsStatusNePastFilter() {
        let request = GetTenantsRequest()

        XCTAssertEqual(request.path, "Tenants")
        XCTAssertEqual(request.method, .get)
        XCTAssertNil(request.body)

        let filtersItem = request.queryItems.first(where: { $0.name == "filters" })
        XCTAssertEqual(filtersItem?.value, "Status,ne,Past")
    }

    func testEmbedsAndFieldsSerializeAsCommaLists() {
        let request = GetTenantsRequest(
            embeds: [.addresses, .contacts, .leases],
            fields: [.addresses, .contacts]
        )

        let embeds = request.queryItems.first(where: { $0.name == "embeds" })?.value
        let fields = request.queryItems.first(where: { $0.name == "fields" })?.value

        XCTAssertEqual(embeds, "Addresses,Contacts,Leases")
        XCTAssertEqual(fields, "Addresses,Contacts")
    }

    func testCustomFiltersOverrideDefault() {
        let request = GetTenantsRequest(filters: [
            RMFilter(key: "PropertyID", operation: "eq", value: "3")
        ])

        let filters = request.queryItems.first(where: { $0.name == "filters" })?.value
        XCTAssertEqual(filters, "PropertyID,eq,3")
    }

    func testEmptyEmbedsAndFieldsAreOmittedFromQuery() {
        let request = GetTenantsRequest()

        XCTAssertNil(request.queryItems.first(where: { $0.name == "embeds" }))
        XCTAssertNil(request.queryItems.first(where: { $0.name == "fields" }))
    }

    func testPageSizeSerializesAsInt() {
        let request = GetTenantsRequest(pageSize: 250)

        let pageSize = request.queryItems.first(where: { $0.name == "pageSize" })?.value
        XCTAssertEqual(pageSize, "250")
    }
}

// MARK: - RMAPIError Status Mapping

final class RMAPIErrorTests: XCTestCase {
    func test401MapsToUnauthorized() {
        let error = RMAPIError.fromStatus(401, data: Data())

        if case .unauthorized = error {
            // ok
        } else {
            XCTFail("Expected .unauthorized, got \(error)")
        }
    }

    func test403MapsToForbidden() {
        if case .forbidden = RMAPIError.fromStatus(403, data: Data()) { return }
        XCTFail("Expected .forbidden")
    }

    func test404MapsToNotFound() {
        if case .notFound = RMAPIError.fromStatus(404, data: Data()) { return }
        XCTFail("Expected .notFound")
    }

    func test429MapsToRateLimited() {
        if case .rateLimited = RMAPIError.fromStatus(429, data: Data()) { return }
        XCTFail("Expected .rateLimited")
    }

    func test500MapsToServerErrorWithBody() {
        let body = "internal explosion".data(using: .utf8)!
        let error = RMAPIError.fromStatus(503, data: body)

        guard case .server(let code, let bodyString) = error else {
            return XCTFail("Expected .server, got \(error)")
        }
        XCTAssertEqual(code, 503)
        XCTAssertEqual(bodyString, "internal explosion")
    }

    func test422MapsToClientErrorNotServerError() {
        let error = RMAPIError.fromStatus(422, data: Data())

        guard case .client(let code, _) = error else {
            return XCTFail("Expected .client for 4xx (non-standard), got \(error)")
        }
        XCTAssertEqual(code, 422)
    }
}

// MARK: - SyncCoordinator Delta Filter

final class SyncCoordinatorTests: XCTestCase {

    override func setUp() async throws {
        try await super.setUp()
        await SyncCoordinator.shared.resetSyncDate(for: RMTenant.self)
    }

    override func tearDown() async throws {
        await SyncCoordinator.shared.resetSyncDate(for: RMTenant.self)
        try await super.tearDown()
    }

    func testDeltaFilterIsNilOnFirstRun() async {
        let filter = await SyncCoordinator.shared.deltaFilter(for: RMTenant.self)
        XCTAssertNil(filter, "First sync should do a full pull, not apply a date filter.")
    }

    func testDeltaFilterUsesUpdateDateGteAfterMarking() async {
        let fixed = Date(timeIntervalSince1970: 1_745_000_000)
        await SyncCoordinator.shared.markSynced(RMTenant.self, at: fixed)

        let filter = await SyncCoordinator.shared.deltaFilter(for: RMTenant.self)
        XCTAssertEqual(filter?.key, "UpdateDate")
        XCTAssertEqual(filter?.operation, "gte")
        // ISO 8601 "Internet Date Time" in UTC for the fixed epoch second.
        XCTAssertEqual(filter?.value, "2025-04-18T18:13:20Z")
    }

    func testResetSyncDateClearsTheDelta() async {
        await SyncCoordinator.shared.markSynced(RMTenant.self)

        let beforeReset = await SyncCoordinator.shared.deltaFilter(for: RMTenant.self)
        XCTAssertNotNil(beforeReset)

        await SyncCoordinator.shared.resetSyncDate(for: RMTenant.self)

        let afterReset = await SyncCoordinator.shared.deltaFilter(for: RMTenant.self)
        XCTAssertNil(afterReset)
    }
}
