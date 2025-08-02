# Performance Benchmark: Equatable & Hashable with Identifiable

This project benchmarks the performance of `Equatable` and `Hashable` conformances in Swift, comparing the default synthesized implementations with a manual implementation that leverages the `Identifiable` protocol.

## The Experiment

The goal is to measure the performance difference when comparing and hashing complex objects.

- **Synthesized Method:** The compiler automatically generates the `==` and `hash(into:)` methods. This is convenient but requires checking every property of the object.
- **Identifiable Method:** We manually implement `==` and `hash(into:)` to only use the `id` property. This is possible because if two objects have the same unique ID, they can be considered equal.

## Methodology

To ensure a fair and direct comparison, all benchmark cases are run for the **same number of iterations (1,000,000)**. The total elapsed time for each test is measured, and the speedup is calculated by taking a direct ratio of these times.

This method, while slower to run, provides a clear and unambiguous measure of the performance difference.

## Final Results

Here is a summary of the final benchmark run:

| Test Case                              | Time (ms)        |
| -------------------------------------- | ---------------- |
| 1. Equatable w/ Identifiable           | 3.30             |
| 2. Equatable (Synthesized)             | 8.20             |
| 3. Equatable (Synthesized, Identical)  | 17.55            |
| 4. Hashable w/ Identifiable            | 8.56             |
| 5. Hashable (Synthesized)              | 193,534.62       |

### Performance Comparison

- **Synthesized Equatable is 2.49x slower** than the `Identifiable`-based implementation.
- **Synthesized Hashable is 22,622.18x slower** than the `Identifiable`-based implementation.

## Conclusion

For complex objects, relying on the synthesized implementations of `Equatable` and `Hashable` can lead to significant performance bottlenecks, especially for hashing.

By conforming to `Identifiable` and implementing a custom `==` and `hash(into:)` that only uses the `id`, you can achieve dramatic performance gains. This is a critical optimization to consider for any application that frequently compares or stores complex objects in collections like `Set` or `Dictionary`.

## How to Run the Benchmark

To reproduce these results:

1.  **Build in release mode:**
    ```sh
    swift build -c release
    ```

2.  **Run the benchmark executable:**
    ```sh
    ./.build/release/benchmark
    ```
