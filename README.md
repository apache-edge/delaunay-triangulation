# Delaunay Triangulation

A Swift implementation of the Delaunay Triangulation algorithm. The Delaunay triangulation of a set of points is a triangulation such that no point is inside the circumcircle of any triangle.

[![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![Swift CI](https://github.com/apache-edge/delaunay-triangulation/actions/workflows/swift.yml/badge.svg)](https://github.com/apache-edge/delaunay-triangulation/actions/workflows/swift.yml)
[![Platforms](https://img.shields.io/badge/platforms-macOS%20|%20iOS%20|%20tvOS%20|%20iPadOS%20|%20visionOS%20|%20Linux%20|%20Windows%20|%20Android-lightgrey.svg)](https://github.com/apache-edge/delaunay-triangulation)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

## Table of Contents

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Basic Usage](#basic-usage)
- [Advanced Usage](#advanced-usage)
- [Error Handling](#error-handling)
- [Performance Considerations](#performance-considerations)
- [Visualization](#visualization)
- [API Reference](#api-reference)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [Algorithm Details](#algorithm-details)
- [License](#license)

## Features

- Pure Swift implementation
- Cross-platform support (macOS, iOS, tvOS, iPadOS, visionOS, Linux, Windows, Android)
- Efficient with conditional importing (FoundationEssentials when available)
- Delaunay triangulation using Bowyer-Watson algorithm
- Voronoi diagram generation
- Robust error handling for edge cases
- Comprehensive test suite using Swift Testing
- CI integration with GitHub Actions via Swiftly v0.1

## Requirements

- Swift 6.0 or later
- macOS 10.15+, iOS 13.0+, tvOS 13.0+, watchOS 6.0+, or Linux with Swift support
- Xcode 15.0+ (for development on Apple platforms)

## Installation

### Swift Package Manager

Add the dependency to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/apache-edge/delaunay-triangulation.git", from: "0.0.1")
]
```

Then add the dependency to your target:

```swift
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            .product(name: "DelaunayTriangulation", package: "delaunay-triangulation")
        ]
    )
]
```

### Manual Installation

1. Clone the repository:
```bash
git clone https://github.com/apache-edge/delaunay-triangulation.git
```

2. Drag the `Sources/DelaunayTriangulation` folder into your Xcode project.

## Basic Usage

### Object-Oriented API

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
```

### Tuple-Based API

```swift
import DelaunayTriangulation

// Using tuple syntax
do {
    let pointTuples = [(0.0, 0.0), (1.0, 0.0), (0.0, 1.0), (1.0, 1.0), (0.5, 0.5)]
    let triangleTuples = try triangulate(points: pointTuples)
    
    // Process tuple-based triangles...
} catch {
    print("Error: \(error)")
}
```

## Advanced Usage

### Handling Large Datasets

For large datasets, consider preprocessing your points to remove duplicates and ensure they're not collinear:

```swift
import DelaunayTriangulation

func preprocessPoints(_ rawPoints: [Point]) -> [Point] {
    // Sort points to make duplicate detection easier
    let sortedPoints = rawPoints.sorted { 
        if $0.x == $1.x { return $0.y < $1.y }
        return $0.x < $1.x 
    }
    
    // Remove duplicates (keeping a small epsilon for floating-point comparison)
    var uniquePoints: [Point] = []
    for point in sortedPoints {
        if let lastPoint = uniquePoints.last, 
           abs(point.x - lastPoint.x) < 1e-10 && abs(point.y - lastPoint.y) < 1e-10 {
            continue
        }
        uniquePoints.append(point)
    }
    
    return uniquePoints
}

// Usage
let rawPoints = generateLargePointSet() // Your function to generate/load points
let processedPoints = preprocessPoints(rawPoints)
do {
    let triangles = try DelaunayTriangulator.triangulate(points: processedPoints)
    // Process triangles...
} catch {
    print("Error: \(error)")
}
```

### Incremental Processing

For very large datasets, you can process points in batches:

```swift
import DelaunayTriangulation

func incrementalTriangulation(batches: [[Point]]) throws -> [Triangle] {
    guard let firstBatch = batches.first else { return [] }
    
    // Start with the first batch
    var triangles = try DelaunayTriangulator.triangulate(points: firstBatch)
    
    // Process remaining batches
    for batch in batches.dropFirst() {
        // Extract all points from current triangulation
        var currentPoints = Set<Point>()
        for triangle in triangles {
            currentPoints.insert(triangle.p1)
            currentPoints.insert(triangle.p2)
            currentPoints.insert(triangle.p3)
        }
        
        // Combine with new batch and re-triangulate
        let combinedPoints = Array(currentPoints) + batch
        triangles = try DelaunayTriangulator.triangulate(points: combinedPoints)
    }
    
    return triangles
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

### Handling Specific Errors

```swift
do {
    let triangles = try DelaunayTriangulator.triangulate(points: points)
    // Process triangles...
} catch DelaunayTriangulationError.collinearPoints {
    // Add a non-collinear point to break collinearity
    var newPoints = points
    newPoints.append(Point(x: points[0].x + 10, y: points[0].y + 10))
    do {
        let triangles = try DelaunayTriangulator.triangulate(points: newPoints)
        // Process triangles...
    } catch {
        print("Still failed after adding non-collinear point: \(error)")
    }
} catch DelaunayTriangulationError.duplicatePoints {
    // Remove duplicates
    let uniquePoints = Array(Set(points))
    do {
        let triangles = try DelaunayTriangulator.triangulate(points: uniquePoints)
        // Process triangles...
    } catch {
        print("Still failed after removing duplicates: \(error)")
    }
} catch {
    print("Unexpected error: \(error)")
}
```

## Performance Considerations

### Time Complexity

- Average case: O(n log n) where n is the number of points
- Worst case: O(n²) for pathological point distributions

### Space Complexity

- O(n) for storing the triangulation

### Optimization Tips

1. **Preprocess Points**: Remove duplicates and check for collinearity before triangulation.
2. **Batch Processing**: For very large datasets, consider processing points in batches.
3. **Memory Management**: For iOS/macOS applications, be mindful of memory usage with large datasets.

## Visualization

### Example Visualization Code (SwiftUI)

```swift
import SwiftUI
import DelaunayTriangulation

struct DelaunayVisualization: View {
    let points: [Point]
    let triangles: [Triangle]
    let voronoiEdges: [Edge]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Draw triangles
                ForEach(0..<triangles.count, id: \.self) { i in
                    let triangle = triangles[i]
                    Path { path in
                        path.move(to: CGPoint(x: triangle.p1.x, y: triangle.p1.y))
                        path.addLine(to: CGPoint(x: triangle.p2.x, y: triangle.p2.y))
                        path.addLine(to: CGPoint(x: triangle.p3.x, y: triangle.p3.y))
                        path.closeSubpath()
                    }
                    .stroke(Color.blue, lineWidth: 1)
                }
                
                // Draw Voronoi edges
                ForEach(0..<voronoiEdges.count, id: \.self) { i in
                    let edge = voronoiEdges[i]
                    Path { path in
                        path.move(to: CGPoint(x: edge.p1.x, y: edge.p1.y))
                        path.addLine(to: CGPoint(x: edge.p2.x, y: edge.p2.y))
                    }
                    .stroke(Color.red, lineWidth: 1)
                }
                
                // Draw points
                ForEach(0..<points.count, id: \.self) { i in
                    let point = points[i]
                    Circle()
                        .fill(Color.black)
                        .frame(width: 5, height: 5)
                        .position(x: point.x, y: point.y)
                }
            }
        }
    }
}
```

### Example Output

Here's what a Delaunay triangulation and its corresponding Voronoi diagram might look like:

```
    A       B
    |\     /|
    | \   / |
    |  \ /  |
    |   X   |
    |  / \  |
    | /   \ |
    |/     \|
    C       D
```

The Delaunay triangulation consists of triangles ABC and ABD, while the Voronoi diagram is represented by the perpendicular bisectors of the edges.

## API Reference

### Core Types

#### Point

```swift
struct Point: Hashable, Equatable {
    let x: Double
    let y: Double
    
    init(x: Double, y: Double)
    
    // Distance calculation
    func distance(to other: Point) -> Double
}
```

#### Edge

```swift
struct Edge: Hashable, Equatable {
    let p1: Point
    let p2: Point
    
    init(p1: Point, p2: Point)
    
    // Normalized edge (p1 is lexicographically smaller than p2)
    var normalized: Edge
}
```

#### Triangle

```swift
struct Triangle: Hashable, Equatable {
    let p1: Point
    let p2: Point
    let p3: Point
    
    init(p1: Point, p2: Point, p3: Point) throws
    
    // Circumcircle properties
    var circumcenter: Point
    var circumradiusSquared: Double
    
    // Check if a point is inside the circumcircle
    func isPointInCircumcircle(_ point: Point) -> Bool
    
    // Check if a point is inside the triangle
    func contains(_ point: Point) -> Bool
}
```

#### DelaunayTriangulator

```swift
enum DelaunayTriangulator {
    // Main triangulation function
    static func triangulate(points: [Point]) throws -> [Triangle]
    
    // Generate Voronoi diagram
    static func voronoiDiagram(from triangles: [Triangle]) -> [Edge]
}
```

### Convenience Functions

```swift
// Tuple-based API
func triangulate(points: [(Double, Double)]) throws -> [(Double, Double, Double, Double, Double, Double)]
```

## Troubleshooting

### Common Issues

#### "All input points are collinear"

**Problem**: The triangulation fails because all points lie on a straight line.

**Solution**: Add at least one point that doesn't lie on the same line:

```swift
var points = [/* your collinear points */]
// Add a point that's clearly not on the same line
points.append(Point(x: points[0].x + 10, y: points[0].y + 10))
```

#### "Input contains duplicate points"

**Problem**: The triangulation fails because there are duplicate or nearly duplicate points.

**Solution**: Filter out duplicates before triangulation:

```swift
let uniquePoints = Array(Set(points))
// Or with a custom epsilon for floating-point comparison
let epsilon = 1e-10
var filteredPoints: [Point] = []
for point in points {
    if !filteredPoints.contains(where: { 
        abs($0.x - point.x) < epsilon && abs($0.y - point.y) < epsilon 
    }) {
        filteredPoints.append(point)
    }
}
```

#### Numerical Precision Issues

**Problem**: Floating-point precision issues causing unexpected results.

**Solution**: Consider scaling your coordinates or using a larger epsilon for comparisons:

```swift
// Scale coordinates
let scaledPoints = points.map { Point(x: $0.x * 1000, y: $0.y * 1000) }

// Use larger epsilon for comparisons
let epsilon = 1e-8
```

## Contributing

Contributions to the Delaunay Triangulation library are welcome! Here's how you can contribute:

1. **Fork the Repository**: Create your own fork of the project.
2. **Create a Branch**: Make your changes in a new branch.
3. **Submit a Pull Request**: Once you've made your changes, submit a pull request.

### Development Setup

1. Clone the repository:
```bash
git clone https://github.com/apache-edge/delaunay-triangulation.git
cd delaunay-triangulation
```

2. Build the project:
```bash
swift build
```

3. Run the tests:
```bash
swift test
```

### Coding Guidelines

- Follow the Swift API Design Guidelines
- Write comprehensive tests for new features
- Document your code with comments
- Update the README if necessary

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

### Complexity

- Time Complexity: O(n log n) average case, O(n²) worst case
- Space Complexity: O(n)

Where n is the number of input points.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.