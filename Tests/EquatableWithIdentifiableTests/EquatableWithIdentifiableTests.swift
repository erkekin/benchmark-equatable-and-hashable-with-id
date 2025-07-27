// This file would be located at: Tests/EquatableWithIdentifiableTests/EquatableWithIdentifiableTests.swift

import XCTest
 @testable import PerformanceBenchmarks

final class EquatableWithIdentifiableTests: XCTestCase {

    var instanceA: CompanyWithIdentifiable!
    var instanceB: CompanyWithIdentifiable!
    var instanceC: CompanyWithIdentifiable!

    override func setUp() {
        super.setUp()
        // Create very large, complex instances
        let idA = UUID()
        let employees = (0..<5000).map { i in
            User(id: UUID(), username: "user\(i)", email: "user\(i) @test.com",
                 profile: Profile(bio: "A very long bio string for user \(i) to add complexity.", lastLogin: Date(), followerCount: i * 10, settings: ["theme": "dark", "notifications": "enabled"]),
                 friends: (0..<100).map { _ in UUID() })
        }
        
        instanceA = CompanyWithIdentifiable(
            id: idA,
            name: "TechCorp A",
            foundedDate: Date(),
            address: Address(street: "123 Innovation Dr", city: "Palo Alto", state: "CA", zipCode: "94301", country: "USA", coordinates: Coordinates(latitude: 37.4419, longitude: -122.1430)),
            employees: employees,
            metadata: ["version": "1.0", "tier": "enterprise"],
            stockSymbol: "TCA"
        )
        
        // Instance B is identical in ID but different in content
        instanceB = CompanyWithIdentifiable(
            id: idA,
            name: "TechCorp A (Updated)",
            foundedDate: Date().addingTimeInterval(-1000),
            address: Address(street: "124 Innovation Dr", city: "Palo Alto", state: "CA", zipCode: "94301", country: "USA", coordinates: Coordinates(latitude: 37.4419, longitude: -122.1430)),
            employees: [],
            metadata: ["version": "2.0", "tier": "enterprise"],
            stockSymbol: "TCA"
        )
        
        // Instance C has a different ID
        instanceC = CompanyWithIdentifiable(
            id: UUID(),
            name: "TechCorp C",
            foundedDate: Date(),
            address: Address(street: "456 Legacy Rd", city: "Austin", state: "TX", zipCode: "73301", country: "USA", coordinates: Coordinates(latitude: 30.2672, longitude: -97.7431)),
            employees: employees,
            metadata: ["version": "1.0", "tier": "startup"],
            stockSymbol: "TCC"
        )
    }

    func testEqualityPerformance_WithIdentifiable() {
        // This should be extremely fast because it only compares the UUIDs.
        measure {
            _ = (instanceA == instanceB) // Should be true
            _ = (instanceA == instanceC) // Should be false
        }
    }
}
