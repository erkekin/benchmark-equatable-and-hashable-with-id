// This file would be located at: Tests/HashableWithoutIdentifiableTests/HashableWithoutIdentifiableTests.swift

import XCTest
 @testable import PerformanceBenchmarks

final class HashableWithoutIdentifiableTests: XCTestCase {

    var instanceA: CompanyHashableOnly!
    var instanceB: CompanyHashableOnly!

    override func setUp() {
        super.setUp()
        let idA = UUID()
        let employees = (0..<5000).map { i in
            User(id: UUID(), username: "user\(i)", email: "user\(i) @test.com",
                 profile: Profile(bio: "A very long bio string for user \(i) to add complexity.", lastLogin: Date(), followerCount: i * 10, settings: ["theme": "dark", "notifications": "enabled"]),
                 friends: (0..<100).map { _ in UUID() })
        }
        
        instanceA = CompanyHashableOnly(
            id: idA,
            name: "TechCorp A",
            foundedDate: Date(),
            address: Address(street: "123 Innovation Dr", city: "Palo Alto", state: "CA", zipCode: "94301", country: "USA", coordinates: Coordinates(latitude: 37.4419, longitude: -122.1430)),
            employees: employees,
            metadata: ["version": "1.0", "tier": "enterprise"],
            stockSymbol: "TCA"
        )
        
        // Instance B has slightly different data
        instanceB = CompanyHashableOnly(
            id: idA,
            name: "TechCorp A (Updated)",
            foundedDate: Date(),
            address: instanceA.address,
            employees: [],
            metadata: ["version": "2.0"],
            stockSymbol: "TCA"
        )
    }

    func testHashingPerformance_WithoutIdentifiable() {
        // This will be very slow. It must hash every single property,
        // including iterating through all 5000 employees.
        // Hashes for A and B should be different.
        measure {
            var hasherA = Hasher()
            instanceA.hash(into: &hasherA)
            _ = hasherA.finalize()

            var hasherB = Hasher()
            instanceB.hash(into: &hasherB)
            _ = hasherB.finalize()
        }
    }
}
