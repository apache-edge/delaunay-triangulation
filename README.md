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
- Robust error handling for edge cases
- Comprehensive test suite using Swift Testing
- CI integration with GitHub Actions via Swiftly v0.1

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
do {
    let triangles = try DelaunayTriangulator.triangulate(points: points)
    
    // Generate Voronoi diagram
    let voronoiEdges = DelaunayTriangulator.voronoiDiagram(from: triangles)
    
    // Process the results...
} catch DelaunayTriangulationError.collinearPoints {
    print("All points are collinear")
} catch DelaunayTriangulationError.duplicatePoints {
    print("Input contains duplicate points")
} catch {
    print("Error: \(error)")
}

// Using tuple syntax
do {
    let pointTuples = [(0.0, 0.0), (1.0, 0.0), (0.0, 1.0), (1.0, 1.0), (0.5, 0.5)]
    let triangleTuples = try triangulate(points: pointTuples)
    
    // Process tuple-based triangles...
} catch {
    print("Error: \(error)")
}
```


## Error Handling

The library provides comprehensive error handling for various edge cases:

```swift
public enum DelaunayTriangulationError: Error, CustomStringConvertible {
    /// Thrown when attempting to triangulate points that lie on a line
    case collinearPoints
    
    /// Thrown when input contains duplicate points
    case duplicatePoints
    
    /// Thrown when attempting to create a triangle with invalid vertices
    case invalidTriangle
    
    /// Thrown when a numerical calculation error occurred
    case numericalError(String)
    
    /// General error with custom message
    case general(String)
}
```

This helps gracefully handle edge cases like collinear or duplicate points.

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

## Algorithm Details

### Overview

Delaunay triangulation is a geometric algorithm that creates a triangulation (a mesh of triangles) for a set of points such that no point is inside the circumcircle of any triangle. This property maximizes the minimum angle of all the angles of the triangles, avoiding skinny triangles.

The Delaunay triangulation has many applications in:
- Computer graphics and terrain modeling
- Mesh generation for finite element methods
- Computational geometry
- Geographic information systems (GIS)
- Wireless network design

### Implementation

This library implements the Bowyer-Watson algorithm, an incremental approach to constructing Delaunay triangulations:

1. Start with a "super triangle" that contains all the points
2. Add points one by one:
   - Find all triangles whose circumcircle contains the new point
   - Remove these triangles, creating a polygon
   - Connect the new point to each vertex of the polygon
3. Remove all triangles that share a vertex with the super triangle

The implementation also provides a method to generate the Voronoi diagram, which is the dual graph of the Delaunay triangulation.

### Data Structures

#### Point

```swift
struct Point {
    let x: Double
    let y: Double
}
```

Represents a 2D point with x and y coordinates.

#### Edge

```swift
struct Edge {
    let p1: Point
    let p2: Point
}
```

Represents an edge between two points. The edge is ordered so that p1 is lexicographically smaller than p2.

#### Triangle

```swift
struct Triangle {
    let p1: Point
    let p2: Point
    let p3: Point
}
```

Represents a triangle defined by three points.

### Key Operations

#### Circumcircle Check

The algorithm relies heavily on testing whether a point lies inside the circumcircle of a triangle. This is done by calculating the circumcenter and radius of the triangle, then checking the distance between the point and the circumcenter.

```swift
func isPointInCircumcircle(_ point: Point) -> Bool
```

#### Triangulation

The main triangulation function takes an array of points and returns an array of triangles:

```swift
static func triangulate(points: [Point]) throws -> [Triangle]
```

#### Voronoi Diagram Generation

The Voronoi diagram is generated from the Delaunay triangulation:

```swift
static func voronoiDiagram(from triangles: [Triangle]) -> [Edge]
```

### Complexity

- Time complexity: O(n log n) on average, where n is the number of points
- Space complexity: O(n)

In the worst case (when most points fall in the circumcircle of most triangles), the time complexity can degrade to O(n²).

## License

This library is released under the MIT license.

## References

1. Bowyer, A. (1981). "Computing Dirichlet tessellations". The Computer Journal. 24 (2): 162–166.
2. Watson, D. F. (1981). "Computing the n-dimensional Delaunay tessellation with application to Voronoi polytopes". The Computer Journal. 24 (2): 167–172.
3. de Berg, M., Cheong, O., van Kreveld, M., & Overmars, M. (2008). "Computational Geometry: Algorithms and Applications" (3rd ed.). Springer-Verlag.
4. O'Rourke, J. (1998). "Computational Geometry in C" (2nd ed.). Cambridge University Press.