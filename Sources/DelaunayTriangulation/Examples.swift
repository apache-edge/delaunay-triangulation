#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

/// Examples demonstrating how to use the Delaunay triangulation library
public enum Examples {
    /// Example of triangulating a simple square with a point in the middle
    public static func triangulateSquare() -> [Triangle] {
        let points = [
            Point(x: 0, y: 0),
            Point(x: 10, y: 0),
            Point(x: 10, y: 10),
            Point(x: 0, y: 10),
            Point(x: 5, y: 5)
        ]
        
        return DelaunayTriangulator.triangulate(points: points)
    }
    
    /// Generate a Voronoi diagram from a set of random points
    public static func generateRandomVoronoi(pointCount: Int = 20, seed: Int = 42) -> [Edge] {
        var seededGenerator = SeededGenerator(seed: UInt64(seed))
        
        var points: [Point] = []
        
        // Generate random points
        for _ in 0..<pointCount {
            let x = Double.random(in: 0...100, using: &seededGenerator)
            let y = Double.random(in: 0...100, using: &seededGenerator)
            points.append(Point(x: x, y: y))
        }
        
        // Triangulate
        let triangles = DelaunayTriangulator.triangulate(points: points)
        
        // Generate Voronoi diagram
        return DelaunayTriangulator.voronoiDiagram(from: triangles)
    }
    
    /// Triangulate a circle of points
    public static func triangulateCircle(pointCount: Int = 16) -> [Triangle] {
        var points: [Point] = []
        
        // Add center point
        points.append(Point(x: 0, y: 0))
        
        // Add points in a circle
        for i in 0..<pointCount {
            let angle = 2.0 * Double.pi * Double(i) / Double(pointCount)
            let x = 10 * cos(angle)
            let y = 10 * sin(angle)
            points.append(Point(x: x, y: y))
        }
        
        return DelaunayTriangulator.triangulate(points: points)
    }
    
    /// Print the triangles in a readable format
    public static func printTriangles(_ triangles: [Triangle]) {
        for (i, triangle) in triangles.enumerated() {
            print("Triangle \(i + 1):")
            print("  Point 1: (\(triangle.p1.x), \(triangle.p1.y))")
            print("  Point 2: (\(triangle.p2.x), \(triangle.p2.y))")
            print("  Point 3: (\(triangle.p3.x), \(triangle.p3.y))")
            print("  Area: \(triangle.area)")
            print("  Circumcenter: (\(triangle.circumcenter.x), \(triangle.circumcenter.y))")
            print("")
        }
        print("Total triangles: \(triangles.count)")
    }
}

/// Random number generator with a seed for reproducible results
public struct SeededGenerator: RandomNumberGenerator {
    private var rng: XorshiftRandomNumberGenerator
    
    public init(seed: UInt64) {
        self.rng = XorshiftRandomNumberGenerator(seed: seed)
    }
    
    public mutating func next() -> UInt64 {
        return rng.next()
    }
}

/// A simple Xorshift random number generator
/// Implementation of xorshift128+ algorithm
struct XorshiftRandomNumberGenerator: RandomNumberGenerator {
    private var state0: UInt64
    private var state1: UInt64
    
    init(seed: UInt64) {
        // Initialize with the seed
        self.state0 = seed &+ 1
        self.state1 = (seed &* 6364136223846793005) &+ 1442695040888963407
        
        // Warm up the generator
        for _ in 0..<10 {
            _ = next()
        }
    }
    
    mutating func next() -> UInt64 {
        var s1 = state0
        let s0 = state1
        state0 = s0
        s1 ^= s1 << 23
        state1 = s1 ^ s0 ^ (s1 >> 18) ^ (s0 >> 5)
        return state1 &+ s0
    }
}