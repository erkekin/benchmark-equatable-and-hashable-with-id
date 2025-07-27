// This file would be located at: Tests/EquatableWithoutIdentifiableTests/EquatableWithoutIdentifiableTests.swift

import XCTest
 @testable import PerformanceBenchmarks

final class EquatableWithoutIdentifiableTests: XCTestCase {

    var instanceA: CompanyEquatableOnly!
    var instanceB: CompanyEquatableOnly!
    var instanceC: CompanyEquatableOnly!

    override func setUp() {
        super.setUp()
        // Create very large, complex instances
        let idA = UUID()
        let employees = (0..<5000).map { i in
            User(id: UUID(), username: "user\(i)", email: "user\(i) @test.com",
                 profile: Profile(bio: "A very long bio string for user \(i) to add complexity.", lastLogin: Date(), followerCount: i * 10, settings: ["theme": "dark", "notifications": "enabled"]),
                 friends: (0..<100).map { _ in UUID() })
        }
        
        instanceA = CompanyEquatableOnly(
            id: idA,
            name: "TechCorp A",
            foundedDate: Date(),
            address: Address(street: "123 Innovation Dr", city: "Palo Alto", state: "CA", zipCode: "94301", country: "USA", coordinates: Coordinates(latitude: 37.4419, longitude: -122.1430)),
            employees: employees,
            metadata: ["version": "1.0", "tier": "enterprise"],
            stockSymbol: "TCA"
        )
        
        // Instance B is a deep copy of A
        instanceB = CompanyEquatableOnly(
            id: idA,
            name: "TechCorp A",
            foundedDate: instanceA.foundedDate,
            address: instanceA.address,
            employees: instanceA.employees,
            metadata: instanceA.metadata,
            stockSymbol: instanceA.stockSymbol
        )
        
        // Instance C has one minor difference deep in the employee list
        var employeesC = employees
        employeesC[4999] = User(id: UUID(), username: "user4999-mod", email: "user4999mod @test.com", profile: employeesC[4999].profile, friends: employeesC[4999].friends)
        
        instanceC = CompanyEquatableOnly(
            id: idA,
            name: "TechCorp A",
            foundedDate: instanceA.foundedDate,
            address: instanceA.address,
            employees: employeesC,
            metadata: instanceA.metadata,
            stockSymbol: instanceA.stockSymbol
        )
    }

    func testEqualityPerformance_WithoutIdentifiable() {
        // This will be very slow. It must compare every single property,
        // including iterating through all 5000 employees and their properties.
        measure {
            _ = (instanceA == instanceB) // Should be true
            _ = (instanceA == instanceC) // Should be false
        }
    }
}
