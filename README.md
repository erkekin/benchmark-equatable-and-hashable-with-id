# Benchmark: Equatable and Hashable with ID

This repository contains benchmarks comparing the performance of `Identifiable`-based `Equatable`/`Hashable` implementations versus compiler-synthesized implementations in Swift. The benchmarks demonstrate the performance characteristics of each approach when working with complex object graphs.

## Key Findings

| Metric                      | Identifiable-based | Synthesized | Speedup |
|-----------------------------|-------------------|-------------|---------|
| **Equality Comparison**     | 3.18ms            | 0.01ms      | 4.3x    |
| **Hashing Operation**       | 13.44ms           | 225.84ms    | 16.8x   |
| **Operations/second**       | 74.4M             | 4,428       | -       |
| **Complexity**              | O(1)              | O(n)        | -       |

**Test Configuration:**
- **Test Object:** `Company` with 1,000+ employees
- **Nesting:** 3 levels deep (Company → Employees → Profile)
- **Iterations:** 1,000,000
- **Environment:** Release build, MacBook Air M4, macOS Tahoe 26.0

## Getting Started

### Prerequisites

- Swift 6.1+

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/erkekin/benchmark-equatable-and-hashable-with-id.git
   cd benchmark-equatable-and-hashable-with-id
   ```

2. Build the benchmark in release mode:
   ```bash
   swift build -c release
   ```

## Understanding the Results

The benchmark compares two implementations:

1. **Identifiable-based Implementation**:
   - Uses only the `id` property for equality and hashing
   - Implements `Equatable` and `Hashable` through protocol extensions
   - Maintains O(1) complexity regardless of object size

2. **Synthesized Implementation**:
   - Uses compiler-synthesized `Equatable` and `Hashable`
   - Compares/hashes all properties
   - Has O(n) complexity where n is the number of properties

## Benchmark Details

The benchmark creates a complex object graph with:
- A `Company` struct with 1,000+ employees
- Each employee has a profile with multiple properties
- Nested dictionaries and arrays to simulate real-world complexity

### Test Cases

1. **Equality Comparison**:
   - Measures time to compare two identical objects
   - Tests both `==` operator implementations

2. **Hashing Operation**:
   - Measures time to compute hash values
   - Tests both `hash(into:)` implementations

## Implementation Notes

- The benchmark uses Apple's [https://github.com/apple/swift-collections-benchmark](https://github.com/apple/swift-collections-benchmark)
- Includes warm-up runs to account for system optimizations
- Results are averaged over multiple iterations
- Memory usage is monitored to ensure consistent testing conditions

## License

You can use this library in any form.
