// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "DelaunayTriangulation",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .tvOS(.v16),
        .watchOS(.v9),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "DelaunayTriangulation",
            targets: ["DelaunayTriangulation"]),
        .executable(
            name: "DelaunayTriangulationCLI",
            targets: ["DelaunayTriangulationCLI"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "DelaunayTriangulation",
            dependencies: []),
        .executableTarget(
            name: "DelaunayTriangulationCLI",
            dependencies: ["DelaunayTriangulation"]),
        .testTarget(
            name: "DelaunayTriangulationTests",
            dependencies: ["DelaunayTriangulation"]),
    ]
)