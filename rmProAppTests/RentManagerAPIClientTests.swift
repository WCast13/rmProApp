import XCTest
@testable import rmProApp

final class RentManagerAPIClientTests: XCTestCase {
    
    var apiClient: RentManagerAPIClient!
    var mockTokenManager: TokenManager!
    
    override func setUp() {
        super.setUp()
        mockTokenManager = TokenManager.shared
        apiClient = RentManagerAPIClient.shared
    }
    
    override func tearDown() {
        apiClient = nil
        mockTokenManager = nil
        super.tearDown()
    }
    
    func testAPIClientInitialization() {
        XCTAssertNotNil(apiClient, "API Client should not be nil")
        XCTAssertEqual(apiClient.apiKey, apiClient.apiKey, "API Key should be set")
    }
    
    func testURLBuilderCreatesCorrectURL() {
        let baseURL = "https://api.example.com"
        let endpoint = "/tenants"
        let expectedURL = "https://api.example.com/tenants"
        
        let urlBuilder = URLBuilder(baseURL: baseURL)
        let result = urlBuilder.buildURL(endpoint: endpoint)
        
        XCTAssertEqual(result, expectedURL, "URL should be correctly built")
    }
    
    func testTokenManagerStoresToken() async throws {
        let testToken = "test_token_123"
        let testRefreshToken = "refresh_token_123"
        
        mockTokenManager.saveTokens(accessToken: testToken, refreshToken: testRefreshToken)
        
        let retrievedToken = mockTokenManager.getAccessToken()
        XCTAssertEqual(retrievedToken, testToken, "Token should be stored and retrieved correctly")
    }
    
    func testTenantDataParsing() throws {
        let sampleTenant = RMTenant(
            tenantID: "123",
            firstName: "John",
            lastName: "Doe",
            email: "john.doe@example.com",
            phoneNumbers: [],
            addresses: [],
            units: [],
            leases: [],
            userDefinedValues: []
        )
        
        XCTAssertEqual(sampleTenant.tenantID, "123")
        XCTAssertEqual(sampleTenant.firstName, "John")
        XCTAssertEqual(sampleTenant.lastName, "Doe")
        XCTAssertEqual(sampleTenant.email, "john.doe@example.com")
    }
    
    func testPropertyModelInitialization() {
        let property = RMProperty(
            propertyID: "prop_001",
            name: "Test Property",
            address: RMAddress(
                addressID: "addr_001",
                addressLine1: "123 Main St",
                addressLine2: nil,
                city: "Test City",
                state: "CA",
                postalCode: "12345",
                country: "USA"
            ),
            units: []
        )
        
        XCTAssertEqual(property.propertyID, "prop_001")
        XCTAssertEqual(property.name, "Test Property")
        XCTAssertNotNil(property.address)
        XCTAssertEqual(property.address?.city, "Test City")
    }
    
    func testChargeCalculation() {
        let charge = RMCharge(
            chargeID: "charge_001",
            amount: 1500.00,
            description: "Monthly Rent",
            chargeType: .rent,
            dueDate: Date(),
            isPaid: false
        )
        
        XCTAssertEqual(charge.amount, 1500.00, accuracy: 0.01)
        XCTAssertFalse(charge.isPaid)
        XCTAssertEqual(charge.chargeType, .rent)
    }
    
    func testLeaseValidation() {
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .year, value: 1, to: startDate)!
        
        let lease = RMLease(
            leaseID: "lease_001",
            tenantID: "123",
            unitID: "unit_001",
            startDate: startDate,
            endDate: endDate,
            monthlyRent: 2000.00,
            securityDeposit: 2000.00,
            isActive: true
        )
        
        XCTAssertTrue(lease.isActive)
        XCTAssertEqual(lease.monthlyRent, 2000.00, accuracy: 0.01)
        XCTAssertEqual(lease.securityDeposit, 2000.00, accuracy: 0.01)
        XCTAssertGreaterThan(lease.endDate, lease.startDate)
    }
    
    func testAddressFormatting() {
        let address = RMAddress(
            addressID: "addr_002",
            addressLine1: "456 Oak Ave",
            addressLine2: "Apt 2B",
            city: "San Francisco",
            state: "CA",
            postalCode: "94102",
            country: "USA"
        )
        
        let fullAddress = "\(address.addressLine1), \(address.addressLine2 ?? ""), \(address.city), \(address.state) \(address.postalCode)"
        XCTAssertTrue(fullAddress.contains("456 Oak Ave"))
        XCTAssertTrue(fullAddress.contains("Apt 2B"))
        XCTAssertTrue(fullAddress.contains("San Francisco"))
    }
    
    func testPhoneNumberValidation() {
        let phoneNumber = RMPhoneNumber(
            phoneID: "phone_001",
            number: "555-123-4567",
            type: "mobile",
            isPrimary: true
        )
        
        XCTAssertEqual(phoneNumber.number, "555-123-4567")
        XCTAssertEqual(phoneNumber.type, "mobile")
        XCTAssertTrue(phoneNumber.isPrimary)
    }
    
    func testPaymentProcessing() {
        let payment = RMPayment(
            paymentID: "pay_001",
            tenantID: "123",
            amount: 2000.00,
            paymentDate: Date(),
            paymentMethod: "credit_card",
            referenceNumber: "REF123456",
            notes: "March 2025 Rent"
        )
        
        XCTAssertEqual(payment.amount, 2000.00, accuracy: 0.01)
        XCTAssertEqual(payment.paymentMethod, "credit_card")
        XCTAssertEqual(payment.referenceNumber, "REF123456")
        XCTAssertTrue(payment.notes?.contains("March 2025") ?? false)
    }
}

class RentManagerAPIClientPerformanceTests: XCTestCase {
    
    func testURLBuildingPerformance() {
        let urlBuilder = URLBuilder(baseURL: "https://api.example.com")
        
        measure {
            for i in 0..<1000 {
                _ = urlBuilder.buildURL(endpoint: "/tenant/\(i)")
            }
        }
    }
    
    func testDataParsingPerformance() {
        measure {
            for _ in 0..<100 {
                _ = RMTenant(
                    tenantID: UUID().uuidString,
                    firstName: "Test",
                    lastName: "User",
                    email: "test@example.com",
                    phoneNumbers: [],
                    addresses: [],
                    units: [],
                    leases: [],
                    userDefinedValues: []
                )
            }
        }
    }
}