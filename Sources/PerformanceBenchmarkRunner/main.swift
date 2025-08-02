import PerformanceBenchmarks
import Foundation
import QuartzCore

// MARK: - Test Data Generation

func generateTestData() -> (
    identifiable1: CompanyWithIdentifiable,
    identifiable2: CompanyWithIdentifiable,
    equatable1: CompanyEquatableOnly,
    equatable2: CompanyEquatableOnly,
    equatable3: CompanyEquatableOnly
) {
    let address = Address(
        street: "123 Tech Street", city: "Silicon Valley", state: "CA", zipCode: "94025", country: "USA",
        coordinates: Coordinates(latitude: 37.7749, longitude: -122.4194)
    )
    
    let employees = (0..<1000).map { i in
        User(
            id: UUID(), username: "user\(i)", email: "user\(i)@company.com",
            profile: Profile(
                bio: "Employee #\(i) with a long bio.",
                lastLogin: Date(), followerCount: i * 100,
                settings: ["theme": "dark", "notifications": "enabled"]
            ),
            friends: (0..<10).map { _ in UUID() }
        )
    }
    
    let metadata: [String: String] = ["version": "1.0.0", "environment": "production"]
    
    let id1 = UUID()
    
    let identifiable1 = CompanyWithIdentifiable(
        id: id1, name: "Tech Corp", foundedDate: Date(), address: address,
        employees: employees, metadata: metadata, stockSymbol: "TECH"
    )
    
    let identifiable2 = CompanyWithIdentifiable(
        id: id1, name: "Different Name", foundedDate: Date(), address: address,
        employees: employees, metadata: metadata, stockSymbol: "DIFF"
    )
    
    let equatable1 = CompanyEquatableOnly(
        id: id1, name: "Tech Corp", foundedDate: Date(), address: address,
        employees: employees, metadata: metadata, stockSymbol: "TECH"
    )
    
    let equatable2 = CompanyEquatableOnly(
        id: id1, name: "Different Name", foundedDate: Date(), address: address,
        employees: employees, metadata: metadata, stockSymbol: "DIFF"
    )
    
    // Identical copy of equatable1
    let equatable3 = CompanyEquatableOnly(
        id: id1, name: "Tech Corp", foundedDate: Date(), address: address,
        employees: employees, metadata: metadata, stockSymbol: "TECH"
    )
    
    return (identifiable1, identifiable2, equatable1, equatable2, equatable3)
}

// MARK: - Benchmarking Infrastructure

@inline(never)
func blackHole<T>(_: T) {}

struct BenchmarkCase {
    let name: String
    let block: () -> Void
}

func measure(label: String, block: () -> Void) -> Double {
    let startTime = CACurrentMediaTime()
    block()
    let timeElapsed = CACurrentMediaTime() - startTime
    blackHole(timeElapsed)
    return timeElapsed
}

// MARK: - Main Execution

func runBenchmarks() {
    print("Generating test data...")
    let testData = generateTestData()
    let iterations = 1_000_000

    print("Warming up...")
    _ = testData.identifiable1 == testData.identifiable2
    _ = testData.equatable1 == testData.equatable2

    let benchmarkCases = [
        BenchmarkCase(name: "1. Equatable w/ Identifiable") {
            for _ in 0..<iterations {
                _ = testData.identifiable1 == testData.identifiable2
            }
        },
        BenchmarkCase(name: "2. Equatable (Synthesized)") {
            for _ in 0..<iterations {
                _ = testData.equatable1 == testData.equatable2
            }
        },
        BenchmarkCase(name: "3. Equatable (Synthesized, Identical)") {
            for _ in 0..<iterations {
                _ = testData.equatable1 == testData.equatable3
            }
        },
        BenchmarkCase(name: "4. Hashable w/ Identifiable") {
            var hasher = Hasher()
            for _ in 0..<iterations {
                testData.identifiable1.hash(into: &hasher)
            }
            _ = hasher.finalize()
        },
        BenchmarkCase(name: "5. Hashable (Synthesized)") {
            var hasher = Hasher()
            for _ in 0..<iterations {
                testData.equatable1.hash(into: &hasher)
            }
            _ = hasher.finalize()
        }
    ]

    print("\n--- Benchmarking (\(iterations) iterations for all tests) ---")
    
    var results: [(name: String, time: Double)] = []
    for testCase in benchmarkCases {
        print("Running: \(testCase.name)...")
        let time = measure(label: testCase.name, block: testCase.block)
        results.append((name: testCase.name, time: time))
    }

    printResults(results: results, iterations: iterations)
}

func printResults(results: [(name: String, time: Double)], iterations: Int) {
    let idEquatableTime = results.first { $0.name.contains("Equatable w/ Identifiable") }!.time
    let synthEquatableTime = results.first { $0.name.contains("Equatable (Synthesized)") && !$0.name.contains("Identical") }!.time
    let idHashableTime = results.first { $0.name.contains("Hashable w/ Identifiable") }!.time
    let synthHashableTime = results.first { $0.name.contains("Hashable (Synthesized)") }!.time

    let eqSpeedup = synthEquatableTime / idEquatableTime
    let hashSpeedup = synthHashableTime / idHashableTime

    print("\n--- Benchmark Results ---")
    print("+----------------------------------------+------------------+")
    print("| Test Case                              | Time (ms)        |")
    print("+----------------------------------------+------------------+")
    for result in results {
        let name = result.name as NSString
        print(String(format: "| %-38s | %12.2f |", name.utf8String ?? "", result.time * 1000))
    }
    print("+----------------------------------------+------------------+")

    print("\n--- Performance Comparison ---")
    print(String(format: "• Synthesized Equatable is %.2fx slower than Identifiable-based Equatable.", eqSpeedup))
    print(String(format: "• Synthesized Hashable is %.2fx slower than Identifiable-based Hashable.", hashSpeedup))
    
    print("\n--- Notes ---")
    print("• All tests run for \(iterations) iterations for consistency.")
    print("• Lower time is better.")
}

print("=== Benchmarking Equatable & Hashable Performance ===")
runBenchmarks()