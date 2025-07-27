// This file would be located at: Sources/PerformanceBenchmarks/Models.swift

import Foundation

// MARK: - Complex Data Structures

public struct Address {
    public let street: String
    public let city: String
    public let state: String
    public let zipCode: String
    public let country: String
    public let coordinates: Coordinates

    public init(street: String, city: String, state: String, zipCode: String, country: String, coordinates: Coordinates) {
        self.street = street
        self.city = city
        self.state = state
        self.zipCode = zipCode
        self.country = country
        self.coordinates = coordinates
    }
}

public struct Coordinates {
    public let latitude: Double
    public let longitude: Double

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

public struct User {
    public let id: UUID
    public let username: String
    public let email: String
    public let profile: Profile
    public let friends: [UUID] // Just IDs to avoid deep nesting issues in this model

    public init(id: UUID, username: String, email: String, profile: Profile, friends: [UUID]) {
        self.id = id
        self.username = username
        self.email = email
        self.profile = profile
        self.friends = friends
    }
}

public struct Profile {
    public let bio: String
    public let lastLogin: Date
    public let followerCount: Int
    public let settings: [String: String]

    public init(bio: String, lastLogin: Date, followerCount: Int, settings: [String : String]) {
        self.bio = bio
        self.lastLogin = lastLogin
        self.followerCount = followerCount
        self.settings = settings
    }
}


// MARK: - Models for Testing

// --- 1. For Equatable & Hashable with Identifiable ---
// The custom extension will handle the logic.
public struct CompanyWithIdentifiable: Identifiable {
    public let id: UUID
    public let name: String
    public let foundedDate: Date
    public let address: Address
    public let employees: [User]
    public let metadata: [String: String]
    public let stockSymbol: String?

    public init(id: UUID, name: String, foundedDate: Date, address: Address, employees: [User], metadata: [String: String], stockSymbol: String?) {
        self.id = id
        self.name = name
        self.foundedDate = foundedDate
        self.address = address
        self.employees = employees
        self.metadata = metadata
        self.stockSymbol = stockSymbol
    }
}

// Conformance is declared, but the implementation will be provided by the constrained extension.
extension CompanyWithIdentifiable: Equatable {}
extension CompanyWithIdentifiable: Hashable {}


// --- 2. For Equatable & Hashable WITHOUT Identifiable ---
// Compiler will synthesize member-wise comparison and hashing.
public struct CompanyEquatableOnly: Equatable, Hashable {
    public let id: UUID
    public let name: String
    public let foundedDate: Date
    public let address: Address
    public let employees: [User]
    public let metadata: [String: String]
    public let stockSymbol: String?

    public init(id: UUID, name: String, foundedDate: Date, address: Address, employees: [User], metadata: [String: String], stockSymbol: String?) {
        self.id = id
        self.name = name
        self.foundedDate = foundedDate
        self.address = address
        self.employees = employees
        self.metadata = metadata
        self.stockSymbol = stockSymbol
    }
}

// --- 3. For Hashable WITHOUT Identifiable ---
// Compiler will synthesize member-wise hashing.
public struct CompanyHashableOnly: Hashable {
    public let id: UUID
    public let name: String
    public let foundedDate: Date
    public let address: Address
    public let employees: [User]
    public let metadata: [String: String]
    public let stockSymbol: String?
    
    public init(id: UUID, name: String, foundedDate: Date, address: Address, employees: [User], metadata: [String: String], stockSymbol: String?) {
        self.id = id
        self.name = name
        self.foundedDate = foundedDate
        self.address = address
        self.employees = employees
        self.metadata = metadata
        self.stockSymbol = stockSymbol
    }
}

// MARK: - Helper Extensions & Nested Conformances

// We need to provide conformance for the nested types for the compiler to synthesize anything.
extension Address: Equatable, Hashable {}
extension Coordinates: Equatable, Hashable {}
extension User: Equatable, Hashable {}
extension Profile: Equatable, Hashable {}


// This is the key extension from the blog post.
// It provides a high-performance, identity-based implementation for any type
// that conforms to both Identifiable and Equatable/Hashable.
extension Equatable where Self: Identifiable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.id == rhs.id
  }
}

extension Hashable where Self: Identifiable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}
