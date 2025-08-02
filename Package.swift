// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "benchmark-equatable-and-hashable-with-id",
    platforms: [
        .macOS(.v12),
    ],
    dependencies: [
    ],
    targets: [
        .executableTarget(
            name: "PerformanceBenchmarkRunner",
            dependencies: [
                "PerformanceBenchmarks",
            ]
        ),
        .target(
            name: "PerformanceBenchmarks",
            dependencies: []
        ),
        .testTarget(
            name: "EquatableWithIdentifiableTests",
            dependencies: ["PerformanceBenchmarks"]
        ),
        .testTarget(
            name: "EquatableWithoutIdentifiableTests",
            dependencies: ["PerformanceBenchmarks"]
        ),
        .testTarget(
            name: "HashableWithIdentifiableTests",
            dependencies: ["PerformanceBenchmarks"]
        ),
        .testTarget(
            name: "HashableWithoutIdentifiableTests",
            dependencies: ["PerformanceBenchmarks"]
        ),
    ]
)
