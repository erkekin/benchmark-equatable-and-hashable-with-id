// swift-tools-version:6.1
import PackageDescription

let package = Package(
  name: "PerformanceBenchmarks",
  platforms: [
    .macOS(.v15)
  ],
  products: [
    .executable(name: "benchmark", targets:
                  ["PerformanceBenchmarkRunner"]),
    .library(
      name: "PerformanceBenchmarks",
      targets: ["PerformanceBenchmarks"]),
  ],
  dependencies: [
    .package(url:
              "https://github.com/apple/swift-collections-benchmark",
             from: "0.0.4"),
  ],
  targets: [
    .executableTarget(
      name: "PerformanceBenchmarkRunner",
      dependencies: [
        "PerformanceBenchmarks",
        .product(name: "CollectionsBenchmark", package:
                  "swift-collections-benchmark"),
      ]),
    .target(
      name: "PerformanceBenchmarks",
      dependencies: []),
    .testTarget(
      name: "EquatableWithIdentifiableTests",
      dependencies: ["PerformanceBenchmarks"]),
    .testTarget(
      name: "EquatableWithoutIdentifiableTests",
      dependencies: ["PerformanceBenchmarks"]),
    .testTarget(
      name: "HashableWithIdentifiableTests",
      dependencies: ["PerformanceBenchmarks"]),
    .testTarget(
      name: "HashableWithoutIdentifiableTests",
      dependencies: ["PerformanceBenchmarks"]),
  ]
)
