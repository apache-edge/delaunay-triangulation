# Delaunay Triangulation

A Swift implementation of the Delaunay Triangulation algorithm. The Delaunay triangulation of a set of points is a triangulation such that no point is inside the circumcircle of any triangle.

[![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![Swift CI](https://github.com/apache-edge/delaunay-triangulation/actions/workflows/swift.yml/badge.svg)](https://github.com/apache-edge/delaunay-triangulation/actions/workflows/swift.yml)
[![Platforms](https://img.shields.io/badge/platforms-macOS%20|%20iOS%20|%20tvOS%20|%20iPadOS%20|%20visionOS%20|%20Linux%20|%20Windows%20|%20Android-lightgrey.svg)](https://github.com/apache-edge/delaunay-triangulation)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

## Features

- Pure Swift implementation
- Cross-platform support (macOS, iOS, tvOS, iPadOS, visionOS, Linux, Windows, Android)
- Efficient with conditional importing (FoundationEssentials when available)
- Delaunay triangulation using Bowyer-Watson algorithm
- Voronoi diagram generation
- Robust handling of edge cases
- Comprehensive test suite using Swift Testing
- CI integration with GitHub Actions via Swiftly 1.0

## Installation

### Swift Package Manager

Add the dependency to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/apache-edge/delaunay-triangulation.git", from: "1.0.0")
]
```

## Usage

```swift
import DelaunayTriangulation

// Create points
let points = [
    Point(x: 0, y: 0),
    Point(x: 1, y: 0),
    Point(x: 0, y: 1),
    Point(x: 1, y: 1),
    Point(x: 0.5, y: 0.5)
]

// Generate Delaunay triangulation
let triangles = DelaunayTriangulator.triangulate(points: points)

// Generate Voronoi diagram
let voronoiEdges = DelaunayTriangulator.voronoiDiagram(from: triangles)

// Using tuple syntax
let pointTuples = [(0.0, 0.0), (1.0, 0.0), (0.0, 1.0), (1.0, 1.0), (0.5, 0.5)]
let triangleTuples = triangulate(points: pointTuples)
```

## Command Line Interface

The package includes a CLI tool for demonstrating the triangulation:

```bash
# Build and run from source
swift run DelaunayTriangulationCLI

# Or download a pre-built binary from the releases page
```

## Optimized Imports

The library uses conditional imports to prefer the lightweight `FoundationEssentials` when available:

```swift
#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif
```

This ensures the best performance across different platforms.

## Continuous Integration

This project uses GitHub Actions with the [vapor/swiftly-action](https://github.com/vapor/swiftly-action) to run tests on both macOS and Linux platforms, ensuring cross-platform compatibility.

## Requirements

- Swift 6.0 or higher
- macOS 13.0+, iOS 16.0+, tvOS 16.0+, watchOS 9.0+, visionOS 1.0+
- Linux with Swift 6.0 toolchain

## License

This library is released under the MIT license.

## References

- [Delaunay triangulation on Wikipedia](https://en.wikipedia.org/wiki/Delaunay_triangulation)
- [Bowyer-Watson algorithm on Wikipedia](https://en.wikipedia.org/wiki/Bowyer%E2%80%93Watson_algorithm)
- [Voronoi diagram on Wikipedia](https://en.wikipedia.org/wiki/Voronoi_diagram)