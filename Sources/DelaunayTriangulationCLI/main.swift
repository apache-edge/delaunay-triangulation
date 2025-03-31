#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif
import DelaunayTriangulation

// Simple automatic demo for Delaunay triangulation
print("Delaunay Triangulation Automatic Demo")
print("====================================")

// Demo 1: Square with center point
print("\n1. Triangulating a square with a center point:")
let triangles = Examples.triangulateSquare()
Examples.printTriangles(triangles)

// Demo 2: Circle of points
print("\n2. Triangulating a circle of 8 points:")
let circleTriangles = Examples.triangulateCircle(pointCount: 8)
print("Created \(circleTriangles.count) triangles")

// Demo 3: Random points with Voronoi diagram
print("\n3. Generating Delaunay triangulation and Voronoi diagram for random points:")
let seed = 42
var generator = SeededGenerator(seed: UInt64(seed))
let count = 10
let points = (0..<count).map { _ in 
    Point(x: Double.random(in: 0...100, using: &generator), 
          y: Double.random(in: 0...100, using: &generator))
}

print("Generated \(count) random points")

let startTime = Date()
let randomTriangles = DelaunayTriangulator.triangulate(points: points)
let triangulationTime = Date().timeIntervalSince(startTime)

print("Triangulation completed in \(triangulationTime) seconds")
print("Created \(randomTriangles.count) triangles")

let voronoiStartTime = Date()
let voronoi = DelaunayTriangulator.voronoiDiagram(from: randomTriangles)
let voronoiTime = Date().timeIntervalSince(voronoiStartTime)

print("Voronoi diagram completed in \(voronoiTime) seconds")
print("Created \(voronoi.count) Voronoi edges")

print("\nDemo completed successfully!")