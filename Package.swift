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
            targets: ["DelaunayTriangulation"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "DelaunayTriangulation",
            dependencies: []),
        .testTarget(
            name: "DelaunayTriangulationTests",
            dependencies: ["DelaunayTriangulation"]),
    ]
)