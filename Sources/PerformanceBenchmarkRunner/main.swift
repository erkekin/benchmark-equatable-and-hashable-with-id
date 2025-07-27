import PerformanceBenchmarks
import Foundation
import QuartzCore

// MARK: - Test Data Generation

func generateTestData() -> (
    identifiable: (CompanyWithIdentifiable, CompanyWithIdentifiable, CompanyWithIdentifiable),
    equatable: (CompanyEquatableOnly, CompanyEquatableOnly, CompanyEquatableOnly)
) {
    // Create a complex address
    let address = Address(
        street: "123 Tech Street",
        city: "Silicon Valley",
        state: "CA",
        zipCode: "94025",
        country: "USA",
        coordinates: Coordinates(latitude: 37.7749, longitude: -122.4194)
    )
    
    // Create a large array of employees to make the struct more complex
    let employees = (0..<1000).map { i in
        User(
            id: UUID(),
            username: "user\(i)",
            email: "user\(i)@company.com",
            profile: Profile(
                bio: "Employee #\(i) with a very long bio to increase the size of the data structure. " +
                     "This makes the performance difference more noticeable in the benchmarks.",
                lastLogin: Date(),
                followerCount: i * 100,
                settings: ["theme": "dark", "notifications": "enabled"]
            ),
            friends: (0..<10).map { _ in UUID() }
        )
    }
    
    // Create metadata to add more complexity
    let metadata: [String: String] = [
        "version": "1.0.0",
        "environment": "production",
        "region": "us-west-2",
        "deployment": "2023-07-27",
        "features": "analytics,notifications,premium"
    ]
    
    // Create Identifiable test data
    let id1 = UUID()
    let id2 = UUID()
    
    let identifiable1 = CompanyWithIdentifiable(
        id: id1,
        name: "Tech Corp",
        foundedDate: Date(),
        address: address,
        employees: employees,
        metadata: metadata,
        stockSymbol: "TECH"
    )
    
    let identifiable2 = CompanyWithIdentifiable(
        id: id1,  // Same ID as identifiable1
        name: "Different Name",
        foundedDate: Date().addingTimeInterval(-1000),
        address: address,
        employees: employees.reversed(),
        metadata: ["different": "value"],
        stockSymbol: "DIFF"
    )
    
    let identifiable3 = CompanyWithIdentifiable(
        id: id2,  // Different ID
        name: "Another Company",
        foundedDate: Date(),
        address: address,
        employees: employees,
        metadata: metadata,
        stockSymbol: "ACO"
    )
    
    // Create Equatable test data
    let equatable1 = CompanyEquatableOnly(
        id: id1,
        name: "Tech Corp",
        foundedDate: Date(),
        address: address,
        employees: employees,
        metadata: metadata,
        stockSymbol: "TECH"
    )
    
    let equatable2 = CompanyEquatableOnly(
        id: id1,  // Same ID as equatable1 but different properties
        name: "Different Name",
        foundedDate: Date().addingTimeInterval(-1000),
        address: address,
        employees: employees.reversed(),
        metadata: ["different": "value"],
        stockSymbol: "DIFF"
    )
    
    let equatable3 = CompanyEquatableOnly(
        id: id2,  // Different ID
        name: "Another Company",
        foundedDate: Date(),
        address: address,
        employees: employees,
        metadata: metadata,
        stockSymbol: "ACO"
    )
    
    return (
        identifiable: (identifiable1, identifiable2, identifiable3),
        equatable: (equatable1, equatable2, equatable3)
    )
}

// MARK: - Benchmarking

func measure<T>(_ label: String, iterations: Int = 1_000_000, _ block: () -> T) -> (result: T, time: Double) {
    let startTime = CACurrentMediaTime()
    let result = block()
    let timeElapsed = CACurrentMediaTime() - startTime
    return (result, timeElapsed)
}

func runBenchmark() {
    print("Generating test data...")
    let testData = generateTestData()
    
    // Warm up the system
    _ = testData.identifiable.0 == testData.identifiable.1
    _ = testData.equatable.0 == testData.equatable.1
    
    // Let the system stabilize
    print("Warming up...")
    for _ in 0..<5 {
        _ = testData.identifiable.0 == testData.identifiable.1
        _ = testData.equatable.0 == testData.equatable.1
    }
    
    print("\n--- Benchmarking (1M iterations) ---")
    
    // 1. Equatable with Identifiable (same ID)
    let (_, idEqualityTime) = measure("1. Equatable w/ Identifiable", iterations: 1_000_000) {
        let a = testData.identifiable.0
        let b = testData.identifiable.1  // Same ID as a
        var result = false
        for _ in 0..<1_000_000 {
            result = a == b
        }
        return result
    }
    
    // 2. Synthesized Equatable (same ID, different properties)
    let (_, eqEqualityTime) = measure("2. Equatable (Synthesized)", iterations: 1_000) {
        let x = testData.equatable.0
        let y = testData.equatable.1  // Same ID, different properties
        var result = false
        for _ in 0..<1_000 {
            result = x == y
        }
        return result
    }
    
    // 3. Hashable with Identifiable
    let (_, idHashTime) = measure("3. Hashable w/ Identifiable", iterations: 1_000_000) {
        let a = testData.identifiable.0
        var hasher = Hasher()
        for _ in 0..<1_000_000 {
            a.hash(into: &hasher)
        }
        return hasher.finalize()
    }
    
    // 4. Synthesized Hashable
    let (_, eqHashTime) = measure("4. Hashable (Synthesized)", iterations: 1_000) {
        let x = testData.equatable.0
        var hasher = Hasher()
        for _ in 0..<1_000 {
            x.hash(into: &hasher)
        }
        return hasher.finalize()
    }
    
    // Calculate operations per second (normalized to 1M ops)
    let idEqPerSec = 1_000_000 / idEqualityTime
    let eqPerSec = 1_000 / eqEqualityTime * 1_000_000  // Scale up from 1K ops
    let idHashPerSec = 1_000_000 / idHashTime
    let eqHashPerSec = 1_000 / eqHashTime * 1_000_000  // Scale up from 1K ops
    
    // Calculate speedups
    let eqSpeedup = eqEqualityTime / idEqualityTime * 1000  // Scale up to 1M iterations
    let hashSpeedup = eqHashTime / idHashTime * 1000  // Scale up to 1M iterations
    
    // Print results in a clean table
    print("\n--- Benchmark Results ---")
    print("+--------------------------------+------------------+------------------+")
    print("| Test Case                      | Time (ms)        | Ops/sec (M)     |")
    print("+--------------------------------+------------------+------------------+")
    print("| 1. Equatable w/ Identifiable  | \(String(format: "%12.2f", idEqualityTime * 1000)) | \(String(format: "%12.2f", idEqPerSec / 1_000_000)) |")
    print("| 2. Equatable (Synthesized)    | \(String(format: "%12.2f", eqEqualityTime * 1000)) | \(String(format: "%12.2f", eqPerSec / 1_000_000)) |")
    print("| 3. Hashable w/ Identifiable   | \(String(format: "%12.2f", idHashTime * 1000)) | \(String(format: "%12.2f", idHashPerSec / 1_000_000)) |")
    print("| 4. Hashable (Synthesized)     | \(String(format: "%12.2f", eqHashTime * 1000)) | \(String(format: "%12.2f", eqHashPerSec / 1_000_000)) |")
    print("+--------------------------------+------------------+------------------+")
    
    // Print detailed comparison
    print("\n--- Performance Comparison ---")
    print("• Identifiable equality: \(String(format: "%.1f", eqSpeedup))x faster than synthesized")
    print("• Identifiable hashing:  \(String(format: "%.1f", hashSpeedup))x faster than synthesized")
    
    // Print final notes
    print("\n--- Notes ---")
    print("• Results are for 1M iterations (scaled from 1K for slower operations).")
    print("• Ops/sec (M) shows millions of operations per second.")
    print("• Lower time is better, higher Ops/sec is better.")
    print("• Identifiable uses only the ID for comparison/hashing.")
    print("• Synthesized compares/hashes all properties (1000+ employees).")
    print("• Test data includes a Company with 1000+ employees and nested objects.")
    print("• Run in Release mode for accurate performance measurements.")
}

// Run the benchmark
print("=== Benchmarking Equatable & Hashable Performance ===\n")
print("This benchmark compares the performance of Identifiable-based")
print("vs. synthesized Equatable and Hashable conformances.\n")
print("Test data includes a Company struct with 1000 employees")
print("and various other properties to simulate a real-world object.\n")

runBenchmark()
