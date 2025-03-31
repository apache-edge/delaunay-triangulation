# Delaunay Triangulation Documentation

## Overview

Delaunay triangulation is a geometric algorithm that creates a triangulation (a mesh of triangles) for a set of points such that no point is inside the circumcircle of any triangle. This property maximizes the minimum angle of all the angles of the triangles, avoiding skinny triangles.

The Delaunay triangulation has many applications in:
- Computer graphics and terrain modeling
- Mesh generation for finite element methods
- Computational geometry
- Geographic information systems (GIS)
- Wireless network design

## Implementation

This library implements the Bowyer-Watson algorithm, an incremental approach to constructing Delaunay triangulations:

1. Start with a "super triangle" that contains all the points
2. Add points one by one:
   - Find all triangles whose circumcircle contains the new point
   - Remove these triangles, creating a polygon
   - Connect the new point to each vertex of the polygon
3. Remove all triangles that share a vertex with the super triangle

The implementation also provides a method to generate the Voronoi diagram, which is the dual graph of the Delaunay triangulation.

## Data Structures

### Point

```swift
struct Point {
    let x: Double
    let y: Double
}
```

Represents a 2D point with x and y coordinates.

### Edge

```swift
struct Edge {
    let p1: Point
    let p2: Point
}
```

Represents an edge between two points. The edge is ordered so that p1 is lexicographically smaller than p2.

### Triangle

```swift
struct Triangle {
    let p1: Point
    let p2: Point
    let p3: Point
}
```

Represents a triangle defined by three points.

## Key Operations

### Circumcircle Check

The algorithm relies heavily on testing whether a point lies inside the circumcircle of a triangle. This is done by calculating the circumcenter and radius of the triangle, then checking the distance between the point and the circumcenter.

```swift
func isPointInCircumcircle(_ point: Point) -> Bool
```

### Triangulation

The main triangulation function takes an array of points and returns an array of triangles:

```swift
static func triangulate(points: [Point]) -> [Triangle]
```

### Voronoi Diagram Generation

The Voronoi diagram is generated from the Delaunay triangulation:

```swift
static func voronoiDiagram(from triangles: [Triangle]) -> [Edge]
```

## Complexity

- Time complexity: O(n log n) on average, where n is the number of points
- Space complexity: O(n)

In the worst case (when most points fall in the circumcircle of most triangles), the time complexity can degrade to O(n²).

## Cross-Platform Support

This implementation is designed to be cross-platform, supporting:
- macOS
- iOS
- tvOS
- watchOS
- visionOS
- Linux (via Swift on Linux)

## References

1. Bowyer, A. (1981). "Computing Dirichlet tessellations". The Computer Journal. 24 (2): 162–166.
2. Watson, D. F. (1981). "Computing the n-dimensional Delaunay tessellation with application to Voronoi polytopes". The Computer Journal. 24 (2): 167–172.
3. de Berg, M., Cheong, O., van Kreveld, M., & Overmars, M. (2008). "Computational Geometry: Algorithms and Applications" (3rd ed.). Springer-Verlag.
4. O'Rourke, J. (1998). "Computational Geometry in C" (2nd ed.). Cambridge University Press.