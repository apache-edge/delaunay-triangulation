#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#elseif os(Windows)
import ucrt
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
        
        do {
            return try DelaunayTriangulator.triangulate(points: points)
        } catch DelaunayTriangulationError.duplicatePoints {
            print("Error: Duplicate points found in input")
            return []
        } catch DelaunayTriangulationError.collinearPoints {
            print("Error: All input points are collinear")
            return []
        } catch {
            print("Error: \(error)")
            return []
        }
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
        do {
            let triangles = try DelaunayTriangulator.triangulate(points: points)
            // Generate Voronoi diagram
            return DelaunayTriangulator.voronoiDiagram(from: triangles)
        } catch {
            print("Error: \(error)")
            return []
        }
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
        
        do {
            return try DelaunayTriangulator.triangulate(points: points)
        } catch {
            print("Error: \(error)")
            return []
        }
    }
    
    /// Example with collinear points to demonstrate error handling
    public static func triangulateCollinearPoints() -> Result<[Triangle], DelaunayTriangulationError> {
        let points = [
            Point(x: 0, y: 0),
            Point(x: 1, y: 1),
            Point(x: 2, y: 2),
            Point(x: 3, y: 3)
        ]
        
        do {
            let triangles = try DelaunayTriangulator.triangulate(points: points)
            return .success(triangles)
        } catch let error as DelaunayTriangulationError {
            return .failure(error)
        } catch {
            return .failure(.general("Unexpected error: \(error)"))
        }
    }
    
    /// Example with duplicate points to demonstrate error handling
    public static func triangulateDuplicatePoints() -> Result<[Triangle], DelaunayTriangulationError> {
        let points = [
            Point(x: 0, y: 0),
            Point(x: 1, y: 1),
            Point(x: 0, y: 0), // Duplicate point
            Point(x: 3, y: 3)
        ]
        
        do {
            let triangles = try DelaunayTriangulator.triangulate(points: points)
            return .success(triangles)
        } catch let error as DelaunayTriangulationError {
            return .failure(error)
        } catch {
            return .failure(.general("Unexpected error: \(error)"))
        }
    }
    
    /// Example with edge case: nearly collinear points
    public static func triangulateNearlyCollinearPoints() -> [Triangle] {
        // Points that are clearly not collinear
        let points = [
            Point(x: 0, y: 0),
            Point(x: 1, y: 0),
            Point(x: 0.5, y: 0.5),  // Clearly not collinear with the other points
            Point(x: 2, y: 0.2)
        ]
        
        do {
            return try DelaunayTriangulator.triangulate(points: points)
        } catch {
            print("Error: \(error)")
            return []
        }
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